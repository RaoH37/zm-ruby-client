module Zm
  module Client
    # objectClass: zimbraCos
    class Cos < Base::Object

      attr_accessor :name, :id, :zimbraId, :zimbraMailQuota, :zimbraMailHostPool

      def init_from_json(json)
        # @id    = json[:id]
        # @name  = json[:name]
        # # puts json

        # # Hash[json[:a].map{|n|['@'+n[:n],n[:_content]]}].each do |k,v|
        # #   self.instance_variable_set(k, convert_json_string_value(v))
        # # end if json[:a]
        # # json[:a].map{|n|['@'+n[:n],n[:_content]]}.reduce({}) { |h, (k, v)| (h[k] ||= []) << v; h }

        # # https://stackoverflow.com/questions/9270972/convert-array-of-2-element-arrays-into-a-hash-where-duplicate-keys-append-addit
        # if json[:a]
        #   hashes = json[:a].map{|n|['@'+n[:n],n[:_content]]}.map{ |pair| Hash[*pair] }
        #   hashes.inject{ |h1,h2| h1.merge(h2){ |*a| a[1,2].flatten } }.each do |k,v|
        #     self.instance_variable_set(k, convert_json_string_value(v))
        #   end
        # end

        # # quick fix
        # # todo
        # # puts @name
        # # puts json
        # # p @zimbraMailHostPool
        super
        @zimbraMailHostPool = [@zimbraMailHostPool] if @zimbraMailHostPool.is_a?(String)
        @zimbraZimletAvailableZimlets = [@zimbraZimletAvailableZimlets] if @zimbraZimletAvailableZimlets.is_a?(String)
      end

      def duplicate(attrs = {})
        # n = clone
        # attrs.each{|k,v| n.instance_variable_set(k, v) }
        # n.id = nil
        # n.zimbraId = nil
        # n
      end

      def modify!
        # sac.modify_cos(id, instance_variables_array)
      end

      def create!
        # sac.create_cos(name, instance_variables_array)
      end

      # def instance_variables_array
      #   Hash[instance_variables.reject{|name| name == :@soap_admin_connector || name == :@id || name == :@name }.map do |name|
      #       [name.to_s[1..-1], instance_variable_get(name)]
      #     end
      #   ]
      # end

      def servers
        @servers ||= get_servers
      end

      private

      def get_servers
        sc = ServersCollection.new self
        @zimbraMailHostPool.map do |server_id|
          sc.find server_id
        end
      end
    end
  end
end
