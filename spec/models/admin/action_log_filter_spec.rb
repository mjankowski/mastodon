# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLogFilter do
  describe described_class::ACTION_TYPE_MAP do
    subject { described_class }

    it 'matches the available dropdown labels' do
      expect(subject.keys)
        .to match_array(I18n.t('admin.action_logs.action_types', locale: :en).keys)
    end

    it 'has messages for each recorded action and target type' do
      subject.each_value do |type|
        key = "admin.action_logs.actions.#{type[:action]}_#{type[:target_type].underscore}_html"

        expect(I18n.exists?(key, :en)).to be(true), "Missing translation: #{key}"
      end
    end
  end
end
