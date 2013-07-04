require 'formal_wear/version'
require 'formal_wear/class_methods'
require 'formal_wear/instance_methods'
require 'formal_wear/suit'
require 'hash_assertions'
require 'active_support/core_ext'
require 'active_support/concern'

module FormalWear
  extend ActiveSupport::Concern

  ### CLASS LEVEL BEHAVIOR
  REQUIRED_KEYS = [:name, :type, :source]
  ALLOWED_KEYS  = REQUIRED_KEYS | [:store, :select_options]

  included do
    extend FormalWear::ClassMethods
    include FormalWear::InstanceMethods

    attr_reader :primary
    cattr_reader :required_fields, :optional_fields

    FormalWear::Suit.up(self)
  end
end