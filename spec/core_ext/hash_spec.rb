require 'spec_helper'

describe Hash do

  subject(:hash){ {foo: 1, bar: 2} }

  describe "#assert_required_keys" do
    it "should raise an error with a missing key" do
      expect { hash.assert_required_keys :baz }.to raise_error ArgumentError
    end

    it "should not raise an error when all keys are present" do
      expect { hash.assert_required_keys :foo, :bar }.to_not raise_error ArgumentError
    end

    it "should not raise an error when required and optional keys are present" do
      expect { hash.assert_required_keys :foo }.to_not raise_error ArgumentError
    end
  end

end
