require 'spec_helper'
require_relative './support/bare_object'

describe BareObject do
  let(:obj) { BareObject }

  context 'including FormalWear' do
    before { obj.send(:include, FormalWear) }

    context 'when required_attr is invoked' do
      before do
        obj.class_eval do
          required_attr dynamic_id: {
            name: "Test",
            type: :text,
            source: ->(s) { nil },
          }
        end
      end

      it 'sets a class variable called @@required_fields' do
        obj.class_variable_defined?(:@@required_fields).should be_true
      end

      it 'adds the given field to @@required_fields' do
        obj.class_variable_get(:@@required_fields).keys.should include(:dynamic_id)
      end

      it 'adds a reader for the field' do
        obj.method_defined?(:dynamic_id).should be_true
      end

      it 'adds a writer for the field' do
        obj.method_defined?(:dynamic_id=).should be_true
      end
    end
  end
end