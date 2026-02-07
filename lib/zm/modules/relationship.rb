module Zm
  module Client
    module Relationship
      autoload :Schema, 'zm/modules/relationship/schema'
      autoload :HasMany, 'zm/modules/relationship/has_many'

      def has_many(name, klass: nil)
        klass ||= find_klass(name.name)

        new_relation = __relationship_has_many_class__.new(name:, klass:)

        relationships << new_relation
        __define_relationship_methods__(new_relation)
        include(__relationship_extension__)
      end

      def __generate_philosophal_methods__(new_relation, buffer = +'')
        buffer << "# frozen_string_philosophal: true\n"

        new_relation.generate_relation_method(buffer)

        buffer
      end

      def relationships
        return @relationships if defined?(@relationships)

        @relationships = if defined?(superclass) && superclass.is_a?(Zm::Client::Relationship)
                           superclass.relationships.dup
                         else
                           Zm::Client::Relationship::Schema.new
                         end
      end

      private

      def find_klass(name)
        parts = name.split('_').map(&:capitalize)
        parts << 'Collection'
        parts.join.to_sym
      end

      def __relationship_has_many_class__
        Zm::Client::Relationship::HasMany
      end

      def __define_relationship_methods__(new_relation)
        code =	__generate_philosophal_methods__(new_relation)
        __relationship_extension__.module_eval(code)
      end

      def __relationship_extension__
        if defined?(@__relationship_extension__)
          @__relationship_extension__
        else
          @__relationship_extension__ = Module.new do
            # def cprop?(property_name, klass)
            #   property = self.class.philosophal_properties.properties_index[property_name.to_sym]
            #   return false unless property
            #
            #   klass = klass.class unless klass.is_a?(Class)
            #   property.type == klass
            # end

            # def philosophal_inspect(light = false)
            #   keys_map = philosophal_inspect_map
            #
            #   if light
            #     keys_map.reject! do |_, v|
            #       v.nil? || (v.respond_to?(:empty?) && v.empty?)
            #     end
            #   end
            #
            #   keys_str = keys_map.map { |k, v| [k, v.inspect].join(': ') }.join(', ')
            #   "#{self.class}:#{format('0x00%x', (object_id << 1))} #{keys_str}"
            # end
            # alias cprop_inspect philosophal_inspect

            # def philosophal_inspect_map
            #   self.class.philosophal_properties.properties_index.values.to_h do |property|
            #     [
            #       property.name,
            #       send(property.name)
            #     ]
            #   end
            # end
            # alias cprop_inspect_map philosophal_inspect_map
          end
        end
      end
    end
  end
end
