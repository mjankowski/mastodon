# frozen_string_literal: true

class Fasp::DebugCallback < ApplicationRecord
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'
end
