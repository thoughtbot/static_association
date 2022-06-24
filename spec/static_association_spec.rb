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

describe StaticAssociation do
  after do
    DummyClass.instance_variable_set(:@index, {})
  end

  describe ".record" do
    it "should add a record" do
      expect {
        DummyClass.record id: 1 do
          self.name = "asdf"
        end
      }.to change(DummyClass, :count).by(1)
    end

    context "id uniqueness" do
      it "should raise an error with a duplicate id" do
        expect {
          DummyClass.record id: 1 do
            self.name = "asdf"
          end

          DummyClass.record id: 1 do
            self.name = "asdf"
          end
        }.to raise_error(StaticAssociation::DuplicateID)
      end
    end

    context "sets up the instance using self" do
      subject {
        DummyClass.record id: 1 do
          self.name = "asdf"
        end
      }

      its(:id) { should == 1 }
      its(:name) { should == "asdf" }
    end

    context "sets up the instance using the object passed in" do
      subject {
        DummyClass.record id: 1 do |c|
          c.name = "asdf"
        end
      }

      its(:id) { should == 1 }
      its(:name) { should == "asdf" }
    end

    context "without a block" do
      subject { DummyClass.record id: 1 }

      its(:id) { should == 1 }
      its(:name) { should be_nil }
    end

    context "asserting valid keys" do
      it "should raise an error" do
        expect {
          DummyClass.record id: 1, foo: :bar
        }.to raise_error(ArgumentError)
      end
    end
  end

  describe "finders" do
    before do
      DummyClass.record id: 1 do
        self.name = "asdf"
      end
    end

    describe ".find" do
      context "record exists" do
        subject { DummyClass.find(1) }

        it { should be_kind_of(DummyClass) }
        its(:id) { should == 1 }
      end

      context "record does not exist" do
        it "should raise a StaticAssociation::RecordNotFoundError" do
          expect {
            DummyClass.find(:not_in_the_index)
          }.to raise_error(StaticAssociation::RecordNotFound)
        end
      end
    end

    describe ".find_by_id" do
      context "record exists" do
        subject { DummyClass.find_by_id(1) }

        it { should be_kind_of(DummyClass) }
        its(:id) { should == 1 }
      end

      context "record does not exist" do
        subject { DummyClass.find_by_id(:not_in_the_index) }
        it { should be_nil }
      end
    end

    describe ".find_by" do
      context "record exists" do
        subject { DummyClass.find_by(id: 1) }

        it { should be_kind_of(DummyClass) }
        its(:id) { should == 1 }
      end

      context "record does not exist" do
        subject { DummyClass.find_by(id: 2) }

        it { should be_nil }
      end

      context "with invalid attributes" do
        it "raises a StaticAssociation::UndefinedAttribute" do
          expect {
            DummyClass.find_by(undefined_attribute: 1)
          }.to raise_error(StaticAssociation::UndefinedAttribute)
        end
      end
    end
  end

  describe ".belongs_to_static" do
    let(:associated_class) { AssociationClass.new }

    it "creates reader method that uses the correct singularized class when finding static association" do
      expect {
        DummyClass.should_receive(:find)
      }
      associated_class.dummy_class
    end

    it "creates a different reader method that uses the specified class when finding static asssociation" do
      expect {
        DummyClass.should_receive(:find)
      }
      associated_class.dodo_class
    end
  end
end
