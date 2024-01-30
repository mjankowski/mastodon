# frozen_string_literal: true

class REST::Admin::CohortSerializer < REST::BaseSerializer
  attributes :frequency

  class CohortDataSerializer < REST::BaseSerializer
    attributes :date, :rate, :value

    def date
      cohort_data.date.iso8601
    end
  end

  has_many :data, serializer: CohortDataSerializer

  attribute :period do
    cohort.period.iso8601
  end
end
