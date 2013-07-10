require 'spec_helper'

describe 'Class#required_attr method' do
  context 'when given unallowed field options' do
    it 'raises an ArgumentError' do
      expect { require_relative('./support/forbidden_option_tester') }.to raise_error(ArgumentError, /Unknown key(\(s\))*: extraneous/)
    end
  end

  context 'when missing required field options' do
    it 'raises an ArgumentError' do
      expect { require_relative('./support/missing_option_tester') }.to raise_error(ArgumentError, /Missing required key(\(s\))*: type/)
    end
  end
end