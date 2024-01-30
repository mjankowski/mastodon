# frozen_string_literal: true

class REST::Admin::MeasureSerializer < REST::BaseSerializer
  attributes :key, :unit

  attribute :data # TODO: eh?

  attribute :total do
    measure.total.to_s
  end

  attribute :human_value, if: -> { measure.respond_to?(:value_to_human_value) } do
    measure.value_to_human_value(measure.total)
  end

  attribute :previous_total, if: -> { measure.total_in_time_range? } do
    measure.previous_total.to_s
  end
end
