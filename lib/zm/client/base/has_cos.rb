# frozen_string_literal: true

module Zm
  module Client
    module Base
      # cos and cos= accessors of an admin object linked to a COS by one of its Zimbra attributes
      module HasCos
        DEFAULT_COS_NAME = 'default'

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

        # COS applied by Zimbra to a mailbox: its own, else the default COS of its domain, else the "default" COS
        module EffectiveCos
          def effective_cos
            cos || @parent.domains.find_by(name: domain_name).cos || @parent.coses.find_by(name: DEFAULT_COS_NAME)
          end
        end
      end
    end
  end
end
