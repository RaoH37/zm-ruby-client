# frozen_string_literal: true

module Zm
  module Inspector
    def to_s
      inspect
    end

    def to_h
      Hash[instance_variables_map]
    end

    def inspect
      keys_str = to_h.map { |k, v| "#{k}: #{v}" }.join(', ')
      "#{self.class}:#{format('0x00%x', (object_id << 1))} #{keys_str}"
    end

    def instance_variables_map
      keys = instance_variables.dup
      keys.delete(:@parent)
      keys.map { |key| [key, instance_variable_get(key)] }
    end
  end
end
