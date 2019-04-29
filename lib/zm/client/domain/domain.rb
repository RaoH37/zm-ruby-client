module Zm
  module Client
    # objectClass: zimbraDomain
    class Domain < Base::AdminObject
      attr_accessor :name, :description, :zimbraDomainName,
                    :zimbraDomainStatus, :zimbraId, :zimbraDomainType,
                    :zimbraDomainDefaultCOSId, :zimbraGalAccountId,
                    :zimbraPreAuthKey

      def accounts
        @accounts ||= AccountsCollection.new(self)
      end

      def init_from_json(json)
        super(json)
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
    end
  end
end
