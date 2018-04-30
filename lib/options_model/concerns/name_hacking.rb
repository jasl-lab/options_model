# frozen_string_literal: true

module OptionsModel
  module Concerns
    module NameHacking
      extend ActiveSupport::Concern

      module ClassMethods
        def name
          @_name
        end

        def name=(value)
          @_name = value
        end
      end
    end
  end
end
