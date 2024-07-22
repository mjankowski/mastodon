# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFilter do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:context) }

    it 'requires non-empty and valid value for context' do
      expect(subject)
        .to_not allow_values(
          [],
          ['invalid']
        )
        .for(:context)
    end
  end

  describe 'Normalizations' do
    it 'cleans up context values' do
      record = described_class.new(context: ['home', 'notifications', 'public    ', ''])

      expect(record.context).to eq(%w(home notifications public))
    end
  end
end
