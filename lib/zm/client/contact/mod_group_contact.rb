# frozen_string_literal: true

module GroupContact
  def init_members_from_json(m)
    return if m.nil?

    @members = m.map { |m| Zm::Client::ConcatMember.new(m[:type], m[:value]) }
  end

  def create!
    rep = @parent.sacc.create_group_contact(@parent.token, l, construct_soap_attrs, construct_soap_node_members)
    init_from_json(rep[:Body][:CreateContactResponse][:cn].first)
  end

  def modify!
    @parent.sacc.modify_group_contact(@parent.token, id, construct_soap_attrs, construct_soap_node_members)
  end

  def construct_soap_attrs
    [[:nickname, @name], [:fullname, @name], [:fileAs, "8:#{@name}"], %i[type group]]
  end

  def add_contacts(contacts)
    contacts = [contacts] unless contacts.is_a?(Array)
    new_members = contacts.map { |c| add_member_by_value(c.id) }
    add_members(new_members)
  end

  def add_members(new_members)
    new_members = [new_members] unless new_members.is_a?(Array)
    @members += new_members
  end

  def add_members_by_values(member_values)
    member_values = [member_values] unless member_values.is_a?(Array)
    current_member_values = @members.map(&:value)
    member_values.reject! { |value| current_member_values.include?(value) }
    member_values.each { |value| add_member_by_value(value) }
  end

  def add_member_by_value(value)
    @members << Zm::Client::ConcatMember.init_by_value(value)
  end

  def delete_members(del_members)
    del_members = [del_members] unless del_members.is_a?(Array)
    @members -= del_members
  end

  def del_members_by_values(member_values)
    member_values = [member_values] unless member_values.is_a?(Array)
    @members.delete_if { |m| member_values.include?(m.value) }
  end

  def ldap_members
    return [] if @members.nil?

    @members.select(&:ldap?)
  end

  def has_ldap_members?
    ldap_members.any?
  end

  def construct_soap_node_members
    if recorded?
      (old_members - @members).each(&:remove!)
      (@members - old_members).each(&:add!)
      (old_members + @members).uniq.reject { |m| m.op.nil? }.map(&:construct_soap_node)
    else
      @members.map(&:construct_soap_node)
    end
  end
end
