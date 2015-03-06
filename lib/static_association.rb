require 'static_association/version'
require 'active_support/concern'
require 'active_support/ordered_hash'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'

module StaticAssociation
  extend ActiveSupport::Concern

  class DuplicateID < StandardError; end
  class RecordNotFound < StandardError; end

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

    def find(id)
      raise RecordNotFound unless index.has_key?(id)
      index[id]
    end

    def record(settings, &block)
      settings.assert_valid_keys(:id)
      id = settings.fetch(:id)
      raise DuplicateID if index.has_key?(id)
      record = self.new(id)
      record.instance_exec(record, &block) if block_given?
      index[id] = record
    end
  end

  module AssociationHelpers
    def belongs_to_static(name, opts = {})
      class_name = opts.fetch(:class_name, name.to_s.camelize)

      self.send(:define_method, name) do
        begin
          foreign_key = self.send("#{name}_id")
          class_name.constantize.find(foreign_key) if foreign_key
        rescue RecordNotFound
          nil
        end
      end

      self.send(:define_method, "#{name}=") do |assoc|
        self.send("#{name}_id=", assoc.id)
      end
    end
  end
end
