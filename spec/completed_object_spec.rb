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
  end
end
