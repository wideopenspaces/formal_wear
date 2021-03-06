module FormalWear
  module InstanceMethods
    ### THE NITTY GRITTY STARTS HERE

    # Start the configuration process
    def initialize(options = {})
      set_sources(options)
      update_sources
      build_objects
    end

    def required_attributes
      sanitize_and_fill_attributes(required_fields)
    end

    def optional_attributes
      sanitize_and_fill_attributes(optional_fields)
    end

    def attributes
      {}.tap do |h|
        h.merge!(required_attributes: required_attributes) if required_attributes
        h.merge!(optional_attributes: optional_attributes) if optional_attributes
      end
    end
    alias_method :to_h, :attributes

    # Return the list of required fields for this configurator
    def required_fields
      @@required_fields
    end

    def optional_fields
      @@optional_fields
    end

    def required_fields_without_custom_stores
      required_fields.reject { |f,o| custom_store?(o) }
    end

    def required_fields_with_custom_stores
      required_fields.select { |f,o| custom_store?(o) }
    end

    def update(attrs)
      raise ArgumentError, "update requires a Hash" unless attrs.is_a?(Hash)
      attrs.each do |field, value|
        send(:"#{field}=", value) if respond_to?(field)
      end
    end

    def update!(attrs)
      update(attrs)
      save if valid?
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

    def build_objects
      self.methods.select { |m| m.match(/build_/) }.each { |m| self.send(:"#{m.to_s.sub(/\Abuild_/, '')}=", self.send(m)) }
    end

    def sanitize_and_fill_attributes(fields)
      fields.deep_dup.each do |field, options|
        fill_attributes!(field, options)
        sanitize_attributes!(options)
      end
    end

    def sanitize_attributes!(options)
      options.slice!(:name, :type, :value, :values)
    end

    def fill_attributes!(field, options)
      options[:value]   = self.send(field)
      populate_select_values(options) if options[:type] == :select
    end

    def populate_select_values(options)
      options[:values]  = options[:select_options].call(self)
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
      end if required_fields
    end
  end
end