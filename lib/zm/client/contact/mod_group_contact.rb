# frozen_string_literal: true

module GroupContact
  def members
    @members ||= Zm::Client::ContactMembersCollection.new(self)
  end

  def jsns_builder
    @jsns_builder ||= Zm::Client::GroupContactJsnsBuilder.new(self)
  end
end
