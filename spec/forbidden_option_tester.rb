class ForbiddenOptionTester
  include FormalWear

  required_attr moms_id: {
    name: "Your mom's id",
    type: :text,
    source: ->(s) { s.primary.thing_to_be_configured },
    extraneous: :thing
  }
end