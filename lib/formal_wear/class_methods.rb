module FormalWear
  module ClassMethods
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