require 'spec_helper'
require_relative './support/test_formal_wear'

describe 'a new FormalWear-ing object' do
  let(:primary) { ExternalObjectOne.new(nil, nil)}
  let(:config) { TestFormalWear.new(primary) }

  subject { config }

  it 'has a required_fields method' do
    subject.should respond_to(:required_fields)
  end

  describe '#required_fields' do
    subject { config.required_fields }
    it { should be_a(Hash) }

    it "should mirror class's @@required_fields" do
      subject.should == config.class.class_variable_get(:@@required_fields)
    end

    it 'contains the appropriate required fields' do
      subject.keys.should =~ [:moms_id, :docs_id, :lambda_lambda_lambda]
    end
  end

  describe '#optional_fields' do
    subject { config.optional_fields }
    it { should be_a(Hash) }

    it "should mirror class's @@optional_fields" do
      subject.should == config.class.class_variable_get(:@@optional_fields)
    end

    it 'contains the appropriate optional fields' do
      subject.keys.should =~ [:i_am_optional]
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

  context 'when supplied with only one source object' do
    let(:config) { TestFormalWear.new(ExternalObjectTwo.new(nil)) }

    it 'sets an instance variable called primary containing the source' do
      config.instance_variable_defined?(:@primary).should be_true
    end

    it 'allows access to the primary object correctly' do
      config.primary.yet_another_thing_to_be_configured.should == 'Stuff'
    end
  end

  context 'when supplied with a Hash of source objects' do
    let(:config) { TestFormalWear.new(sources: {
        object_two: ExternalObjectTwo.new("I am a secondary") } ) }

    it 'sets an instance variable called sources containing the sources' do
      config.instance_variable_defined?(:@sources).should be_true
    end

    it 'sets instance variables for each source object by name' do
      config.instance_variable_defined?(:@object_two).should be_true
    end

    it 'sets a reader for each source object' do
      config.respond_to?(:object_two).should be_true
    end

    it 'allows access to the source object correctly' do
      config.object_two.another_thing_to_be_configured.should == "I am a secondary"
    end
  end

  describe '#attributes' do
    context 'given an object that contains required and optional attrs' do
      it 'returns a hash containing appropriate keys' do
        config.attributes.keys.should include(:required_attributes, :optional_attributes)
      end
    end
  end

  describe '#required_attributes' do
    it 'removes all options except name, type and value' do
      config.required_attributes.each do |r,o|
        o.should_not include([:source, :store, :select_options])
      end
    end

    it 'adds value to the options' do
      config.required_attributes.each do |r,o|
        o.should include(:value)
      end
    end

    context 'given type :text' do
      it 'does not add values to the options' do
        config.required_attributes.each do |r,o|
          o.should_not include(:values)
        end
      end
    end
  end

  describe '#optional_attributes' do
    it 'removes all options except name, type and value' do
      config.optional_attributes.each do |r,o|
        o.should_not include([:source, :store, :select_options])
      end
    end

    it 'adds value to the options' do
      config.optional_attributes.each do |r,o|
        o.should include(:value)
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

  describe '#update' do
    context 'given anything other than a hash' do
      subject { config.update("Bob") }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, 'update requires a Hash' )
      end
    end

    context 'given a hash of params' do
      subject { config.update(docs_id: 1, nonexistent_id: 4) }
      it 'does not raise an error' do
        expect { subject }.to_not raise_error(ArgumentError)
      end

      it 'updates local attributes based on input' do
        subject
        config.docs_id.should == 1
      end

      it 'should ignore attributes that do not exist' do
        subject
        config.respond_to?(:nonexistent_id).should be_false
      end
    end
  end

  describe '#update!' do
    let!(:params) { { moms_id: 1, docs_id: 2, lambda_lambda_lambda: 3 } }

    it 'should update docs_id' do
      config.expects(:valid?).returns(false)
      config.update!(params)
      config.docs_id.should eq(2)
    end

    context 'if object is valid' do
      before { config.expects(:save).returns(false) }

      it 'should invoke #save' do
        config.update!(params)
      end
    end

    context 'if object is invalid' do
      before { config.expects(:save).never }

      it 'should not invoke #save' do
        config.update!(params.except(:lambda_lambda_lambda))
      end

      it 'should return false' do
        config.update!(params.except(:lambda_lambda_lambda)).should be_false
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