# frozen_string_literal: true

module Zm
  module Client
    module Base
      # cos and cos= accessors of an admin object linked to a COS by one of its Zimbra attributes
      module HasCos
        DEFAULT_COS_NAME = 'default'
        NOT_INHERITED_FROM_COS = %i[cn description zimbraNotes].freeze

        def has_cos(attribute, effective: false)
          define_cos_reader(:"@#{attribute}")
          define_cos_writer(:"#{attribute}=")
          include(EffectiveCos) if effective
        end

        private

        def define_cos_reader(ivar)
          define_method(:cos) do
            id = instance_variable_get(ivar)
            return nil if id.nil?
            return @cos if @cos&.id == id

            @cos = @parent.coses.find_by(id:)
          end
        end

        def define_cos_writer(setter)
          define_method(:cos=) do |value|
            unless value.nil? || (value.is_a?(Cos) && value.recorded?)
              raise ArgumentError, "cos must be nil or a recorded Zm::Client::Cos, got #{value.class}"
            end

            @cos = value
            public_send(setter, value&.id)
          end
        end

        # COS applied by Zimbra to a mailbox (its own, else the default COS of its domain, else the "default" COS)
        # and reset of the mailbox attributes to the values inherited from it
        module EffectiveCos
          def effective_cos
            cos || @parent.domains.find_by(name: domain_name).cos || @parent.coses.find_by(name: DEFAULT_COS_NAME)
          end

          def reset_to_cos!(cos: effective_cos)
            reset = attrs_equal_to_cos(cos)
            return reset if reset.empty?

            hash = reset.to_h { |name| [name, ''] }
            do_update!(hash)
            do_update_attributes(hash)
            reset
          end

          private

          def attrs_equal_to_cos(cos)
            cos_inheritable_attrs.select { |name| same_as_cos_value?(public_send(name), cos.public_send(name)) }
          end

          def cos_inheritable_attrs
            (self.class.zimbra_attrs_writable & Cos.zimbra_attrs_writable) - NOT_INHERITED_FROM_COS
          end

          def same_as_cos_value?(value, cos_value)
            !value.nil? && !cos_value.nil? && same_zimbra_values?(value, cos_value)
          end
        end
      end
    end
  end
end
