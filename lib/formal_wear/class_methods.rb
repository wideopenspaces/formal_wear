module FormalWear
  module ClassMethods
    def build(name, block)
      create_accessors([name])
      define_build_method(name, block)
    end

    def create_accessors(keys)
      keys.each { |k| self.send(:attr_accessor, k) unless method_defined?(k) }
    end

    def define_build_method(name, block)
      define_method(:"build_#{name}") { block.call }
    end

    def validate_attrs!(attrs)
      attrs.each do |a, opts|
        opts.assert_valid_keys(*ALLOWED_KEYS)
        opts.assert_required_keys(*required_keys(opts))
      end
    end

    def required_keys(opts)
      opts[:type] == :select ? REQUIRED_KEYS + [:select_options] : REQUIRED_KEYS
    end
  end
end