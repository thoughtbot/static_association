require "static_association/version"
require "active_support/concern"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/hash/keys"
require "active_support/core_ext/string/inflections"

module StaticAssociation
  extend ActiveSupport::Concern

  class ArgumentError < StandardError; end

  class DuplicateID < StandardError; end

  class RecordNotFound < StandardError; end

  class UndefinedAttribute < StandardError; end

  attr_reader :id

  private

  def initialize(id)
    @id = id
  end

  module ClassMethods
    include Enumerable

    delegate :each, to: :all

    def index
      @index ||= {}
    end

    def all
      index.values
    end

    def ids
      index.keys
    end

    def find(id)
      find_by_id(id) or raise RecordNotFound.new(
        "Couldn't find DummyClass with 'id'=#{id}"
      )
    end

    def find_by_id(id)
      index[
        Integer(id, exception: false) || id
      ]
    end

    def where(id: [])
      all.select { |record| id.include?(record.id) }
    end

    def find_by(**args)
      args.any? or raise ArgumentError

      all.find { |record| matches_attributes?(record: record, attributes: args) }
    end

    def record(settings, &block)
      settings.assert_valid_keys(:id)
      id = settings.fetch(:id)

      if index.has_key?(id)
        raise DuplicateID.new("Duplicate record with 'id'=#{id} found")
      end

      record = new(id)
      record.instance_exec(record, &block) if block
      index[id] = record
    end

    private

    def matches_attributes?(record:, attributes:)
      attributes.all? do |attribute, value|
        record.respond_to?(attribute) or raise UndefinedAttribute.new(
          "Undefined attribute '#{attribute}'"
        )

        record.public_send(attribute) == value
      end
    end
  end

  module AssociationHelpers
    def belongs_to_static(name, opts = {})
      class_name = opts.fetch(:class_name, name.to_s.camelize)

      send(:define_method, name) do
        foreign_key = send(:"#{name}_id")
        class_name.constantize.find_by_id(foreign_key)
      end

      send(:define_method, "#{name}=") do |assoc|
        send(:"#{name}_id=", assoc.id)
      end
    end
  end
end
