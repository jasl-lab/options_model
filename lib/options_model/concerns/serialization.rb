# frozen_string_literal: true

module OptionsModel
  module Concerns
    module Serialization
      extend ActiveSupport::Concern

      def to_h
        hash = {}

        hash.merge! unused_attributes if self.class.with_unused_attributes?
        self.class.attribute_names_for_inlining.each do |name|
          hash[name] = send(name)
        end
        self.class.attribute_names_for_nesting.each do |name|
          hash[name] = send(name).to_h
        end

        hash
      end

      module ClassMethods
        def dump(obj)
          return YAML.dump({}) unless obj

          unless obj.is_a? self
            raise ArgumentError,
                  "can't dump: was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
          end

          YAML.dump obj.to_h
        end

        def load(yaml)
          return new unless yaml
          return new unless yaml.is_a?(String) && /^---/.match?(yaml)

          hash = YAML.safe_load(yaml, permitted_classes: permitted_attribute_classes) || {}

          unless hash.is_a? Hash
            raise ArgumentError,
                  "can't load: was supposed to be a #{Hash}, but was a #{hash.class}. -- #{hash.inspect}"
          end

          new hash
        end

        def with_unused_attributes!
          @with_unused_attributes = true
        end

        def with_unused_attributes?
          @with_unused_attributes
        end

        def permitted_attribute_classes
          @permitted_attribute_classes ||= []
        end
      end
    end
  end
end
