require 'formal_wear/version'
require 'hash_assertion'
require 'active_support/concern'

module FormalWear
  extend ActiveSupport::Concern

  ### CLASS LEVEL BEHAVIOR
  REQUIRED_KEYS = [:name, :type, :source]
  ALLOWED_KEYS  = REQUIRED_KEYS | [:store, :select_options]

  included do
    attr_reader :appointment_book
    cattr_reader :required_fields
  end

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

  ### THE NITTY GRITTY STARTS HERE

  # Start the configuration process
  def initialize(appointment_book)
    @appointment_book = appointment_book
    update_sources
  end

  def required_attributes
    required_fields.dup.each do |field, options|
      options.slice!(:name, :type)
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
    AppointmentBook.transaction { yield if block_given? }
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

  # When loading the Configurator, pre-populate from source
  # if available
  def update_sources
    required_fields.each do |field, options|
      send(:"#{field}=", options[:source].call(appointment_book)) if options[:source] rescue nil
    end
  end
end
