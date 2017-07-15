module OptionsModel
  module Concerns
    module NameHacking
      extend ActiveSupport::Concern

      module ClassMethods
        def name
          @_name
        end

        def name=(value)
          unless /^[A-Z][a-zA-Z_0-9]*$/ =~ value
            raise ArgumentError, "`name` must a valid class name"
          end

          @_name = value
        end
      end
    end
  end
end
