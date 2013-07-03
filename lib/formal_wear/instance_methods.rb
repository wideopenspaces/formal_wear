module FormalWear
  module InstanceMethods
    ### THE NITTY GRITTY STARTS HERE

    # Start the configuration process
    def initialize(options = {})
      set_sources(options)
      update_sources
    end

    def required_attributes
      required_fields.deep_dup.each do |field, options|
        options.slice!(:name, :type)
        options[:value] = self.send(field)
      end
    end

    # Return the list of required fields for this configurator
    def required_fields
      @@required_fields
    end

    def required_fields_without_custom_stores
      required_fields.reject { |f,o| custom_store?(o) }
    end

    def required_fields_with_custom_stores
      required_fields.select { |f,o| custom_store?(o) }
    end

    def to_h
      {}.merge(required_attributes: required_attributes).tap do |h|
        required_fields.keys.each { |k| h[k] = self.send(k) }
      end
    end

    def update(attrs)
      raise ArgumentError, "update requires a Hash"
      attrs.each do |field, value|
        self.send(:"#{field}=", value) if instance_method_defined?(field)
      end
    end

    def valid?
      required_fields.keys.all? { |k| self.send(k).present? }
    end

    def save
      return false unless valid?
      saving do
        required_fields.each { |field, options| set_field(field, options) }
      end
    end

    private

    # Redefine this in a configurator if you need to do anything before you save the data
    def before_save
    end

    # Redefine this in a configurator in order to run tasks after completing setup
    def after_save
    end

    def saving(&block)
      before_save
      yield if block_given?
      after_save
    end

    def set_field(field, options)
      custom_store?(options) ? set_via_custom_store(field, options) : self.send(:"set_#{field}")
    end

    def set_via_custom_store(field, options)
      return set_via_symbol(options) if symbol_store?(options)
      return set_via_lambda(field, options) if lambda_store?(options)
    end

    def set_via_symbol(options)
      self.send(options[:store])
    end

    def set_via_lambda(field, options)
      callable = options[:store]
      self.instance_eval(&callable)
    end

    def custom_store?(options)
      options[:store].present?
    end

    def symbol_store?(options)
      custom_store?(options) && options[:store].is_a?(Symbol)
    end

    def lambda_store?(options)
      custom_store?(options) && options[:store].try(:lambda?)
    end

    def set_sources(options)
      set_primary(options) and return unless options.is_a?(Hash)
      if options[:sources].present?
        @sources = options[:sources]
        set_source_readers
      end
    end

    def set_primary(source)
      @primary = source
    end

    def set_source_readers
      @sources.each { |alt, obj| set_source_reader(alt, obj) }
    end

    def set_source_reader(alt, obj)
      class_eval { attr_reader alt }
      instance_variable_set(:"@#{alt}", obj)
    end

    # When donning formal_wear, pre-populate from source if available
    def update_sources
      required_fields.each do |field, options|
        send(:"#{field}=", options[:source].call(self)) if options[:source] rescue nil
      end
    end
  end
end