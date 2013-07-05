require 'spec_helper'
require_relative './support/test_formal_wear'

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

    describe '#lambda_lambda_lambda' do
      it 'equals ExternalObjectTwo.yet_another_thing_to_be_configured' do
        subject.lambda_lambda_lambda = subject.primary.dependent_object.yet_another_thing_to_be_configured
      end

      it 'equals the method cited in its source attr' do
        subject.lambda_lambda_lambda = subject.send(:get_pledged)
      end
    end

    describe '#i_am_optional' do
      it 'is defined' do
        subject.respond_to?(:i_am_optional).should be_true
      end

      it 'is nil' do
        subject.i_am_optional.should be_nil
      end
    end
  end
end
