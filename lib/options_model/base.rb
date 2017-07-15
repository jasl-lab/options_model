module OptionsModel
  class Base
    include ActiveModel::Model
    include OptionsModel::Concerns::Serialization
    include OptionsModel::Concerns::Attributes
    include OptionsModel::Concerns::AttributeAssignment

    validate do
      self.class.attribute_names.each do |attribute_name|
        attribute = public_send(attribute_name)
        if attribute.is_a?(self.class) && attribute.invalid?
          errors.add attribute_name, :invalid
        end
      end
    end

    def ==(other)
      other.instance_of?(self.class) &&
        attributes == other.attributes &&
        nested_attributes == other.nested_attributes &&
        unused_attributes == other.unused_attributes
    end
    alias :eql? :==

    def hash
      [attributes, nested_attributes, unused_attributes].hash
    end

    def inspect
      "#<#{self.class.name}:OptionsModel #{self.to_h}>"
    end

    def self.inspect
      "#<#{name}:OptionsModel [#{attribute_names.map(&:inspect).join(', ')}]>"
    end

    def persisted?
      true
    end

    def self.derive(name)
      Class.new(self) do
        include OptionsModel::Concerns::NameHacking
        self.name = name
      end
    end
  end
end
