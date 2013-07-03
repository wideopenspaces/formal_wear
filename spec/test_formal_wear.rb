require 'formal_wear'

class TestFormalWear
  include FormalWear

  required_attr moms_id: {
    name: "Your mom's id",
    type: :text,
    source: ->(s) { s.primary.thing_to_be_configured },
  }

  required_attr docs_id: {
    name: "Your doc's id",
    type: :text,
    source: ->(s) { s.primary.dependent_object.another_thing_to_be_configured },
    store: :set_my_docs_id
  }

  required_attr lambda_lambda_lambda: {
    name: 'Revenge Of The Nerds!',
    type: :text,
    source: ->(s) { s.get_pledged },
    store:  ->(s) { s.got_lambda? }
  }

  protected

  def after_save
    # no-op
  end

  def set_moms_id
    # no-op
  end

  def set_my_docs_id
    # no-op
  end

  def got_lambda?
    # no-op
  end

  def get_pledged
    primary.dependent_object.another_thing_to_be_configured
  end
end

class ExternalObjectOne
  attr_accessor :thing_to_be_configured, :dependent_object

  def initialize(initial_value, initial_subvalue)
    @thing_to_be_configured = initial_value
    @dependent_object = ExternalObjectTwo.new(initial_subvalue)
  end

end

class ExternalObjectTwo
  attr_accessor :another_thing_to_be_configured

  def initialize(initial_value)
    @another_thing_to_be_configured = initial_value
  end

  def yet_another_thing_to_be_configured
    "Stuff"
  end
end
