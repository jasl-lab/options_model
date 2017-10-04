# frozen_string_literal: true

module OptionsModel
  module Concerns
    module Attributes
      extend ActiveSupport::Concern

      module ClassMethods
        def attribute(name, cast_type, default: nil, array: false)
          check_not_finalized!

          name = name.to_sym
          check_name_validity! name

          ActiveModel::Type.lookup(cast_type)

          attribute_defaults[name] = default
          default_extractor =
            case
            when default.respond_to?(:call)
              ".call"
            when default.duplicable?
              ".deep_dup"
            else
              ""
            end

          generated_attribute_methods.synchronize do
            generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{name}
              value = attributes[:#{name}]
              return value unless value.nil?
              attributes[:#{name}] = self.class.attribute_defaults[:#{name}]#{default_extractor}
              attributes[:#{name}]
            end
            STR

            if array
              generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
              def #{name}=(value)
                if value.respond_to?(:to_a)
                  attributes[:#{name}] = value.to_a.map { |i| ActiveModel::Type.lookup(:#{cast_type}).cast(i) }
                elsif value.nil?
                  attributes[:#{name}] = self.class.attribute_defaults[:#{name}]#{default_extractor}
                else
                  raise ArgumentError,
                        "`value` should respond to `to_a`, but got \#{value.class} -- \#{value.inspect}"
                end
              end
              STR
            else
              generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
              def #{name}=(value)
                attributes[:#{name}] = ActiveModel::Type.lookup(:#{cast_type}).cast(value)
              end
              STR

              if cast_type == :boolean
                generated_attribute_methods.send :alias_method, :"#{name}?", name
              end
            end
          end

          self.attribute_names_for_inlining << name

          self
        end

        def enum_attribute(name, enum, default: nil, allow_nil: false)
          check_not_finalized!

          unless enum.is_a?(Array) && enum.any?
            raise ArgumentError, "enum should be an Array and can't empty"
          end
          enum = enum.map(&:to_s)

          attribute name, :string, default: default

          pluralized_name = name.to_s.pluralize
          generated_class_methods.synchronize do
            generated_class_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{pluralized_name}
              %w(#{enum.join(" ")}).freeze
            end
            STR

            validates name, inclusion: {in: enum}, allow_nil: allow_nil
          end

          self
        end

        def embeds_one(name, class_name: nil, anonymous_class: nil)
          check_not_finalized!

          if class_name.blank? && anonymous_class.nil?
            raise ArgumentError, "must provide at least one of `class_name` or `anonymous_class`"
          end

          name = name.to_sym
          check_name_validity! name

          if class_name.present?
            nested_classes[name] = class_name.constantize
          else
            nested_classes[name] = anonymous_class
          end

          generated_attribute_methods.synchronize do
            generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{name}
              nested_attributes[:#{name}] ||= self.class.nested_classes[:#{name}].new(attributes[:#{name}])
            end
            STR

            generated_attribute_methods.module_eval <<-STR, __FILE__, __LINE__ + 1
            def #{name}=(value)
              klass = self.class.nested_classes[:#{name}]
              if value.respond_to?(:to_h)
                nested_attributes[:#{name}] = klass.new(value.to_h)
              elsif value.is_a? klass
                nested_attributes[:#{name}] = value
              elsif value.nil?
                nested_attributes[:#{name}] = klass.new
              else
                raise ArgumentError,
                      "`value` should respond to `to_h` or \#{klass}, but got \#{value.class}"
              end
            end
            STR
          end

          self.attribute_names_for_nesting << name

          self
        end

        def attribute_defaults
          @attribute_defaults ||= ActiveSupport::HashWithIndifferentAccess.new
        end

        def nested_classes
          @nested_classes ||= ActiveSupport::HashWithIndifferentAccess.new
        end

        def attribute_names_for_nesting
          @attribute_names_for_nesting ||= Set.new
        end

        def attribute_names_for_inlining
          @attribute_names_for_inlining ||= Set.new
        end

        def attribute_names
          attribute_names_for_nesting + attribute_names_for_inlining
        end

        def finalized?
          @finalized ||= false
        end

        def finalize!(nested = true)
          if nested
            nested_classes.values.each &:finalize!
          end

          @finalized = true
        end

        protected

        def check_name_validity!(symbolized_name)
          if dangerous_attribute_method?(symbolized_name)
            raise ArgumentError, "#{symbolized_name} is defined by #{OptionsModel::Base}. Check to make sure that you don't have an attribute or method with the same name."
          end

          if attribute_names_for_inlining.include?(symbolized_name) || attribute_names_for_nesting.include?(symbolized_name)
            raise ArgumentError, "duplicate define attribute `#{symbolized_name}`"
          end
        end

        def check_not_finalized!
          if finalized?
            raise "can't modify finalized #{self}"
          end
        end

        # A method name is 'dangerous' if it is already (re)defined by OptionsModel, but
        # not by any ancestors. (So 'puts' is not dangerous but 'save' is.)
        def dangerous_attribute_method?(name) # :nodoc:
          method_defined_within?(name, OptionsModel::Base)
        end

        def method_defined_within?(name, klass, superklass = klass.superclass) # :nodoc:
          if klass.method_defined?(name) || klass.private_method_defined?(name)
            if superklass.method_defined?(name) || superklass.private_method_defined?(name)
              klass.instance_method(name).owner != superklass.instance_method(name).owner
            else
              true
            end
          else
            false
          end
        end

        def generated_attribute_methods
          @generated_attribute_methods ||= Module.new {
            extend Mutex_m
          }.tap { |mod| include mod }
        end

        def generated_class_methods
          @generated_class_methods ||= Module.new {
            extend Mutex_m
          }.tap { |mod| extend mod }
        end
      end
    end
  end
end
