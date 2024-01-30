# frozen_string_literal: true

class REST::Admin::DimensionSerializer < REST::BaseSerializer
  attributes(
    :data,
    :key
  )
end
