module FormalWear
  module ClassMethods
    def required_attrs(attrs)
      validate_attrs!(attrs)

      required = class_variable_get(:@@required_fields) || {}
      class_variable_set(:@@required_fields, required.merge(attrs))

      create_accessors(attrs.keys)
    end
    def required_attr(a); required_attrs(a); end

    def create_accessors(keys)
      keys.each { |k| self.send(:attr_accessor, k) unless method_defined?(k) }
    end

    def validate_attrs!(attrs)
      attrs.each do |a, opts|
        opts.assert_valid_keys(*ALLOWED_KEYS)
        opts.assert_required_keys(*REQUIRED_KEYS)
      end
    end
  end
end