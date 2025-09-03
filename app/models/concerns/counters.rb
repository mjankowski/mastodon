# frozen_string_literal: true

module Counters
  extend ActiveSupport::Concern

  class_methods do
    def counter_columns(*columns)
      columns.each do |name|
        attribute name, :counting_number
      end
    end
  end
end
