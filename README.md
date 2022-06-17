# StaticAssociation

![test](https://github.com/thoughtbot/static_association/actions/workflows/test.yml/badge.svg)
![lint](https://github.com/thoughtbot/static_association/actions/workflows/lint.yml/badge.svg)

Adds basic ActiveRecord-like associations to static data.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "static_association"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install static_association

## Usage

### Static Models

Create your static association class:

```ruby
class Day
  include StaticAssociation

  attr_accessor :name

  record id: 0 do |day|
    day.name = :monday
  end
end
```

Calling `record` will allow you to create an instance of this static model, a unique id is mandatory. The newly created object is yielded to the passed block.

The `Day` class will gain an `all` and `find` method.

### Associations

Currently just a 'belongs to' association can be created. This behaviour can be mixed into an `ActiveRecord` model:

```ruby
class Event < ActiveRecord::Base
  extend StaticAssociation::AssociationHelpers

  belongs_to_static :day
end
```

This assumes your model has a field `day_id`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Run lint checks and tests (`bundle exec rake`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
