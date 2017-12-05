# frozen_string_literal: true

require "active_model"
require "active_model/type"

require "options_model/concerns/attribute_assignment"
require "options_model/concerns/attributes"
require "options_model/concerns/name_hacking"
require "options_model/concerns/serialization"

require "options_model/base"

unless defined?(ActiveModel::Type)
  require "active_model/type"
end

module OptionsModel
end
