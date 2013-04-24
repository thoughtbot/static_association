# StaticAssociation

Adds basic ActiveRecord like associations to static data.

This has been extracted from ProjectsDB and Hotleads, see the `BudgetCategory`, `Project` and `ArchiveReason`, `Lead` classes respectively for examples.

## Installation

Add this line to your application's Gemfile:

    gem 'static_association'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install static_association

## Usage

### Static Models

Create your static association class:

    class Days
      include StaticAssociation

      attr_accessor :name

      record id: 0 do |day|
        day.name = :monday
      end
    end

Calling `record` will allow you to create an instance of this static model, a unique id is mandatory. The newly created object is yielded to the passed block.

The `Days` class will gain an `all` and `find` method.

### Associations

Currently just a 'belongs to' association can be created. This behaviour can be mixed into an `ActiveRecord` model:

    belongs_to_static :day

This assumes your model has a field `day_id`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
