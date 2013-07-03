# FormalWear

[![Build Status](https://travis-ci.org/wideopenspaces/formal_wear.png)](https://travis-ci.org/wideopenspaces/formal_wear.png) [![Code Climate](https://codeclimate.com/github/wideopenspaces/formal_wear.png)](https://codeclimate.com/github/wideopenspaces/formal_wear) [![Coverage Status](https://coveralls.io/repos/wideopenspaces/formal_wear/badge.png)](https://coveralls.io/r/wideopenspaces/formal_wear) [![Dependency Status](https://gemnasium.com/wideopenspaces/formal_wear.png)](https://gemnasium.com/wideopenspaces/formal_wear)

"You're going to like the way you look. I guarantee it."

FormalWear helps you create Form Objects with required and optional attributes and gets all fancy widdit.

## Installation

Add this line to your application's Gemfile:

    gem 'formal_wear'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install formal_wear

## Usage

```ruby
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
```

Including FormalWear into your class adds a `required_attrs` and `required_attr` methods.
Specifying a required attr, like so:

```ruby
  required_attr lambda_lambda_lambda: {
    name: 'Revenge Of The Nerds!',
    type: :text,
    source: ->(s) { s.get_pledged },
    store:  ->(s) { s.got_lambda? }
  }
```

adds the attribute to the list of required_fields, and populates it from the source specified
in its hash when your class is initialized.

### Instantiating

```ruby
  TestFormalWear.new(primary_object)
```

... where primary object you will use to fetch values from their source. (TODO: add support for multiple sources)

### Specifying sources

The source option takes a lambda that accepts `self` as its argument. This allows you to use a
method within your class to fetch the information needed from its source, or to directly fetch it
using the `primary` object set when you instantiated the class.

Source is a required attribute, but it can return nil if you feel so inclined. It's a bit like going commando
under that tuxedo, though.

## TODO

* Add `optional_attr/optional_attrs` methods
* (Maybe?) Add helper methods for providing data for working with forms
* Add support for type: :select
* Remove primary

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
