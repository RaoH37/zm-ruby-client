module Zm
  module Client
    class ClusterConfig
      attr_accessor :zimbra_admin_host, :zimbra_admin_scheme,
                    :zimbra_admin_port, :zimbra_admin_login,
                    :zimbra_admin_password, :zimbra_public_host,
                    :zimbra_public_scheme, :zimbra_public_port,
                    :domains
      
      def initialize(file_config_path = nil)
        if block_given?
          yield(self)
          @to_h = instance_variables
        else
          init_from_json(file_config_path)
        end
      end

      def init_from_json(file_config_path)
        @to_h = JSON.parse(File.read(file_config_path), symbolize_names: true)

        @zimbra_admin_host = @to_h[:zimbra_admin_host]
        @zimbra_admin_scheme = @to_h[:zimbra_admin_scheme]
        @zimbra_admin_port = @to_h[:zimbra_admin_port]
        @zimbra_admin_login = @to_h[:zimbra_admin_login]
        @zimbra_admin_password = @to_h[:zimbra_admin_password]
        @zimbra_public_host = @to_h[:zimbra_public_host]
        @zimbra_public_scheme = @to_h[:zimbra_public_scheme]
        @zimbra_public_port = @to_h[:zimbra_public_port]

        @domains = @to_h[:domains].map do |h|
          ClusterConfigDomain.new(h[:name], h[:key])
        end
      end

      def domain_key(domain_name)
        @domains.find { |d| d.name == domain_name }.key
      end

      def to_h
        @to_h
      end
    end

    class ClusterConfigDomain

      attr_reader :name, :key

      def initialize(name, key)
        @name = name
        @key = key
      end
    end
  end
end
