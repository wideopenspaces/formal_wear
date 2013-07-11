require 'spec_helper'
require_relative './support/bare_object'
require_relative './support/new_object'
require 'pry'

describe BareObject do
  let(:obj) { BareObject }

  context 'including FormalWear' do
    before { obj.send(:include, FormalWear) }

    context 'when build is invoked' do
      before do
        obj.class_eval do
          build :new_obj, -> { NewObject.new }
        end
      end

      it 'creates a reader called new_obj' do
        obj.method_defined?(:new_obj).should be_true
      end

      it 'creates a method called build_new_obj' do
        obj.method_defined?(:build_new_obj).should be_true
      end

      context 'and BareObject is instantiated' do
        let!(:new_object) { NewObject.new }
        subject { BareObject.new(ExternalObjectOne.new('Formal', 'Wear')) }

        it 'invokes build_new_obj' do
          BareObject.any_instance.expects(:build_new_obj).returns(true)
          subject
        end

        it 'creates a NewObj' do
          NewObject.expects(:new).returns(new_object)
          subject
        end

        it 'stores NewObj in @new_obj' do
          subject.new_obj.should be_a(NewObject)
        end
      end
    end

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

    context 'when optional_attr is invoked' do
      before do
        obj.class_eval do
          optional_attr optional_id: {
            name: "Test",
            type: :text,
            source: ->(s) { nil },
          }
        end
      end

      it 'sets a class variable called @@optional_attr' do
        obj.class_variable_defined?(:@@optional_fields).should be_true
      end

      it 'adds the given field to @@optional_attr' do
        obj.class_variable_get(:@@optional_fields).keys.should include(:optional_id)
      end

      it 'adds a reader for the field' do
        obj.method_defined?(:optional_id).should be_true
      end

      it 'adds a writer for the field' do
        obj.method_defined?(:optional_id=).should be_true
      end
    end
  end
end