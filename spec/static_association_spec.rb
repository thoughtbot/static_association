require "spec_helper"
require "static_association"

class DummyClass
  include StaticAssociation
  attr_accessor :name
end

class AssociationClass
  attr_accessor :dummy_class_id
  attr_accessor :dodo_class_id

  extend StaticAssociation::AssociationHelpers
  belongs_to_static :dummy_class
  belongs_to_static :dodo_class, class_name: "DummyClass"
end

RSpec.describe StaticAssociation do
  after do
    DummyClass.instance_variable_set(:@index, {})
  end

  describe ".record" do
    it "adds a record" do
      expect { DummyClass.record(id: 1) { self.name = "test" } }
        .to change(DummyClass, :count).by(1)
    end

    context "when using `self`" do
      it "assigns attributes" do
        record = DummyClass.record(id: 1) { self.name = "test" }

        expect(record.id).to eq(1)
        expect(record.name).to eq("test")
      end
    end

    context "when using the object" do
      it "assigns attributes" do
        record = DummyClass.record(id: 1) { |i| i.name = "test" }

        expect(record.id).to eq(1)
        expect(record.name).to eq("test")
      end
    end

    context "when the id is a duplicate" do
      it "raises an error" do
        DummyClass.record(id: 1) { self.name = "test0" }

        expect { DummyClass.record(id: 1) { self.name = "test1" } }
          .to raise_error(
            StaticAssociation::DuplicateID,
            "Duplicate record with 'id'=1 found"
          )
      end
    end

    context "when an attribute is not defined" do
      it "raises an error" do
        expect { DummyClass.record(id: 1) { self.foo = "bar" } }
          .to raise_error(NoMethodError)
      end
    end

    context "when a key is invalid" do
      it "raises an error" do
        expect { DummyClass.record(id: 1, foo: "bar") }
          .to raise_error(ArgumentError)
      end
    end

    context "without a block" do
      it "adds a record" do
        expect { DummyClass.record(id: 1) }.to change(DummyClass, :count).by(1)
      end
    end
  end

  describe ".all" do
    it "returns all records" do
      record1 = DummyClass.record(id: 1)
      record2 = DummyClass.record(id: 2)

      records = DummyClass.all

      expect(records).to contain_exactly(record1, record2)
    end
  end

  describe ".ids" do
    it "returns array of ids for all records" do
      _record1 = DummyClass.record(id: 1)
      _record2 = DummyClass.record(id: 2)

      ids = DummyClass.ids

      expect(ids).to contain_exactly(1, 2)
    end
  end

  describe ".find" do
    context "when the record exists" do
      it "returns the record" do
        record = DummyClass.record(id: 1)

        found_record = DummyClass.find(1)

        expect(found_record).to eq(record)
      end
    end

    context "when the record does not exist" do
      it "raises an error" do
        expect { DummyClass.find(1) }
          .to raise_error(
            StaticAssociation::RecordNotFound,
            "Couldn't find DummyClass with 'id'=1"
          )
      end
    end

    context "when argument is numeric string" do
      it "returns the record" do
        record = DummyClass.record(id: 1)

        found_record = DummyClass.find("1")

        expect(found_record).to eq(record)
      end
    end
  end

  describe ".find_by_id" do
    context "when the record exists" do
      it "returns the record" do
        record = DummyClass.record(id: 1)

        found_record = DummyClass.find_by_id(1)

        expect(found_record).to eq(record)
      end
    end

    context "when the record does not exist" do
      it "returns nil" do
        found_record = DummyClass.find_by_id(1)

        expect(found_record).to be_nil
      end
    end

    context "when id argument is a numeric string" do
      it "returns the record" do
        record = DummyClass.record(id: 1)

        found_record = DummyClass.find_by_id("1")

        expect(found_record).to eq(record)
      end
    end

    context "when id argument is a non-numeric string" do
      it "returns the record" do
        DummyClass.record(id: 1)

        found_record = DummyClass.find_by_id("foo")

        expect(found_record).to be_nil
      end
    end

    context "when record ids are strings and id argument matches a record" do
      it "returns the record" do
        record = DummyClass.record(id: "foo")

        found_record = DummyClass.find_by_id("foo")

        expect(found_record).to eq(record)
      end
    end

    context "when record ids are strings and id argument doesn't match a record" do
      it "returns nil" do
        DummyClass.record(id: "foo")

        found_record = DummyClass.find_by_id("bar")

        expect(found_record).to be_nil
      end
    end
  end

  describe ".where" do
    it "returns all records with the given ids" do
      record1 = DummyClass.record(id: 1)
      _record2 = DummyClass.record(id: 2)
      record3 = DummyClass.record(id: 3)

      results = DummyClass.where(id: [1, 3, 4])

      expect(results).to contain_exactly(record1, record3)
    end

    describe ".find_by" do
      context "when record exists with the specified attribute value" do
        it "returns the record" do
          record1 = DummyClass.record(id: 1) do |r|
            r.name = "foo"
          end
          _record2 = DummyClass.record(id: 2) do |r|
            r.name = "bar"
          end

          found_record = DummyClass.find_by(name: "foo")

          expect(found_record).to eq(record1)
        end
      end

      context "when no record exists that matches the specified attribute value" do
        it "returns nil" do
          DummyClass.record(id: 1) do |r|
            r.name = "foo"
          end

          found_record = DummyClass.find_by(name: "bar")

          expect(found_record).to be_nil
        end
      end

      context "when multiple records match the specified attribute value" do
        it "returns the first matching record" do
          record1 = DummyClass.record(id: 1) do |r|
            r.name = "foo"
          end
          _record2 = DummyClass.record(id: 2) do |r|
            r.name = "foo"
          end

          found_record = DummyClass.find_by(name: "foo")

          expect(found_record).to eq(record1)
        end
      end

      context "when specifying multiple attribute values" do
        it "returns the record matching all attributes" do
          _record1 = DummyClass.record(id: 1) do |r|
            r.name = "foo"
          end
          record2 = DummyClass.record(id: 2) do |r|
            r.name = "foo"
          end

          found_record = DummyClass.find_by(id: 2, name: "foo")

          expect(found_record).to eq(record2)
        end
      end

      context "when specifying multiple attribute values but no record " \
              "matches all attributes" do
        it "returns nil" do
          _record1 = DummyClass.record(id: 1) do |r|
            r.name = "foo"
          end

          found_record = DummyClass.find_by(id: 1, name: "bar")

          expect(found_record).to be_nil
        end
      end

      context "with undefined attributes" do
        it "raises an error" do
          DummyClass.record(id: 1)

          expect {
            DummyClass.find_by(undefined_attribute: 1)
          }.to raise_error(
            StaticAssociation::UndefinedAttribute,
            "Undefined attribute 'undefined_attribute'"
          )
        end
      end

      context "with no attributes" do
        it "raises a StaticAssociation::ArgumentError" do
          expect {
            DummyClass.find_by
          }.to raise_error(StaticAssociation::ArgumentError)
        end
      end
    end
  end

  describe ".find_by!" do
    context "when record exists with the specified attribute value" do
      it "returns the record" do
        record1 = DummyClass.record(id: 1) do |r|
          r.name = "foo"
        end
        _record2 = DummyClass.record(id: 2) do |r|
          r.name = "bar"
        end

        found_record = DummyClass.find_by!(name: "foo")

        expect(found_record).to eq(record1)
      end
    end

    context "when no record exists that matches the specified attribute value" do
      it "raises an error" do
        DummyClass.record(id: 1) do |r|
          r.name = "foo"
        end

        expect {
          DummyClass.find_by!(name: "bar")
        }.to raise_error(
          StaticAssociation::RecordNotFound,
          "Couldn't find DummyClass with name=bar"
        )
      end
    end

    context "when multiple records match the specified attribute value" do
      it "returns the first matching record" do
        record1 = DummyClass.record(id: 1) do |r|
          r.name = "foo"
        end
        _record2 = DummyClass.record(id: 2) do |r|
          r.name = "foo"
        end

        found_record = DummyClass.find_by!(name: "foo")

        expect(found_record).to eq(record1)
      end
    end

    context "when specifying multiple attribute values" do
      it "returns the record matching all attributes" do
        _record1 = DummyClass.record(id: 1) do |r|
          r.name = "foo"
        end
        record2 = DummyClass.record(id: 2) do |r|
          r.name = "foo"
        end

        found_record = DummyClass.find_by!(id: 2, name: "foo")

        expect(found_record).to eq(record2)
      end
    end

    context "when specifying multiple attribute values but no record " \
            "matches all attributes" do
      it "raises an error" do
        _record1 = DummyClass.record(id: 1) do |r|
          r.name = "foo"
        end

        expect {
          DummyClass.find_by!(id: 1, name: "bar")
        }.to raise_error(
          StaticAssociation::RecordNotFound,
          "Couldn't find DummyClass with id=1, name=bar"
        )
      end
    end

    context "with undefined attributes" do
      it "raises a StaticAssociation::UndefinedAttribute" do
        DummyClass.record(id: 1)

        expect {
          DummyClass.find_by!(undefined_attribute: 1)
        }.to raise_error(
          StaticAssociation::UndefinedAttribute,
          "Undefined attribute 'undefined_attribute'"
        )
      end
    end

    context "with no attributes" do
      it "raises a StaticAssociation::ArgumentError" do
        expect {
          DummyClass.find_by!
        }.to raise_error(StaticAssociation::ArgumentError)
      end
    end
  end

  describe ".belongs_to_static" do
    it "defines a reader method for the association" do
      associated_class = AssociationClass.new
      allow(DummyClass).to receive(:find_by_id)

      associated_class.dummy_class

      expect(DummyClass).to have_received(:find_by_id)
    end

    context "when `class_name` is specified" do
      it "defines a reader method for the association" do
        associated_class = AssociationClass.new
        allow(DummyClass).to receive(:find_by_id)

        associated_class.dodo_class

        expect(DummyClass).to have_received(:find_by_id)
      end
    end
  end
end
