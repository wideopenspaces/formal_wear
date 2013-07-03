require 'spec_helper'
require 'test_formal_wear'

describe TestFormalWear do
  let(:primary) { ExternalObjectOne.new(nil, nil)}
  let(:config) { TestFormalWear.new(primary) }

  describe 'a configurator with completed setup' do
    let(:ready_primary) { ExternalObjectOne.new('Formal', 'Wear') }
    let(:ready_config) { TestFormalWear.new(ready_primary)  }

    subject { ready_config }

    context 'when initialized' do
      describe '#moms_id' do
        it 'is equal to ExternalObjectOne.thing_to_be_configured' do
          subject.moms_id.should == subject.primary.thing_to_be_configured
        end
      end

      describe '#docs_id' do
        it 'is equal to ExternalObjectTwo.another_thing_to_be_configured' do
          subject.docs_id.should == subject.primary.dependent_object.another_thing_to_be_configured
        end
      end
    end
  end

  describe 'a new configurator object' do
    subject { config }

    it 'has a required_fields method' do
      subject.should respond_to(:required_fields)
    end

    describe '#required_fields' do
      subject { config.required_fields }
      it { should be_a(Hash) }

      it 'contains the appropriate required fields' do
        subject.keys.should =~ [:moms_id, :docs_id, :lambda_lambda_lambda]
      end
    end

    it 'has a valid? method' do
      subject.should respond_to(:valid?)
    end

    it 'has a getter method for each of the required fields' do
      subject.required_fields.keys.each do |k|
        subject.should respond_to(k)
      end
    end

    it 'has a setter method for each of the required fields' do
      subject.required_fields.keys.each do |k|
        subject.should respond_to(:"#{k}=")
      end
    end

    context 'when a required field has a "store" key' do
      context 'that is a symbol' do
        it 'responds to a method corresponding to that symbol' do
          subject.should respond_to(subject.required_fields[:docs_id][:store])
        end
      end
    end

    context 'when a required field does not have a "store" key' do
      it 'responds to a set_xxx method for each required field' do
        config.required_fields_without_custom_stores.each do |field, options|
          subject.should respond_to(:"set_#{field}")
        end
      end
    end

    describe '.required_attr' do
      context 'when given unallowed field options' do
        it 'raises an ArgumentError' do
          expect { require('forbidden_option_tester') }.to raise_error(ArgumentError, "Unknown key: extraneous")
        end
      end

      context 'when missing required field options' do
        it 'raises an ArgumentError' do
          expect { require('missing_option_tester') }.to raise_error(ArgumentError, /Missing required key:/)
        end
      end
    end
  end

  describe '#valid?' do
    subject { config }

    context 'when none of the required fields are set' do
      before do
        config.moms_id = nil
      end

      it 'returns false' do
        config.valid?.should be_false
      end
    end

    context 'when not all of the required fields are set' do
      before do
        config.moms_id = 'zztop'
      end

      it 'returns false' do
        config.valid?.should be_false
      end
    end

    context 'when all of the required fields are set' do
      before do
        config.moms_id = config.docs_id = config.lambda_lambda_lambda = '1'
      end

      it 'returns true' do
        config.valid?.should be_true
      end
    end
  end

  describe '#save' do
    subject { config }

    context 'when not valid?' do
      it 'returns false' do
        subject.save.should be_false
      end
    end

    context 'when valid?' do
      before do
        subject.moms_id = subject.docs_id = subject.lambda_lambda_lambda = '1'
        subject.required_fields_without_custom_stores.keys.each do |k|
          subject.expects("set_#{k}").returns(true)
        end

        subject.required_fields_with_custom_stores.each do |field, opt|
          if opt[:store].is_a?(Symbol)
            subject.expects(opt[:store]).returns(true)
            subject.expects(:"set_#{field}").never
          elsif opt[:store].try(:lambda?)
           subject.expects(:got_lambda?).returns(true)
          end
        end

        subject.expects(:after_save).returns(true)
      end

      it 'calls the set_xxx methods for each required field' do
        subject.save
      end

      it 'calls #after_save' do
        # condition met by expectation above
        subject.save
      end
    end
  end

end