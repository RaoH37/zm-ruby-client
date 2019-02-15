module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::Object
      attr_accessor :name, :description, :zimbraDomainName,
                    :zimbraDomainStatus, :zimbraId, :zimbraDomainType,
                    :zimbraDomainDefaultCOSId, :zimbraGalAccountId,
                    :zimbraPreAuthKey
      # attr_reader :soap_admin_connector

      def accounts
        # puts "Domain accounts self #{self.class} #{self.object_id} #{self.soap_admin_connector}"
        # puts "Domain accounts parent #{@parent.class} #{@parent.object_id} #{@parent.soap_admin_connector}"
        @accounts ||= AccountsCollection.new(self)
      end

      def init_from_json(json)
        @id    = json[:id]
        @name  = json[:name]
        return unless json[:a].is_a? Array

        n_key = :n
        c_key = :_content
        at_key = '@'

        attrs = {}

        # TODO: definir ici le typage fort des attributs pour ne pas avoir
        # a faire des cases sur les class des attributs dans le code.

        json[:a].each do |a|
          k = "#{at_key}#{a[n_key]}".to_sym
          v = a[c_key]
          if !attrs[k].nil?
            attrs[k] = [attrs[k]] unless attrs[k].is_a?(Array)
            attrs[k].push(v)
          else
            attrs[k] = v
          end
        end

        attrs.each { |k, v| instance_variable_set(k, v) }
      end

      # def quotas
      #   rep = sac.get_quota_usage(name, 1)
      #   # puts rep
      #   AccountsBuilder.new(sac, rep).make
      # end

      # def quotas!
      #   @accounts = quotas
      #   # TODO: il faudrait merger quotas dans @accounts
      # end
    end
  end
end
