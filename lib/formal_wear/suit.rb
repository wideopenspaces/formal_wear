module FormalWear
  module Suit
    def self.up(klass)
      class << klass
        [:optional, :required].each do |kind|
          define_method :"#{kind}_attrs" do |attrs|
            validate_attrs!(attrs)

            var = class_variable_get(:"@@#{kind}_fields") || {}
            class_variable_set(:"@@#{kind}_fields", var.merge(attrs))

            create_accessors(attrs.keys)
          end
          alias :"#{kind}_attr" :"#{kind}_attrs"
        end
      end
    end
  end
end