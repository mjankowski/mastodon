# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Tags' do
  before { sign_in Fabricate(:admin_user) }

  describe 'PUT /admin/tags/:id' do
    let(:tag) { Fabricate :tag }

    it 'gracefully handles invalid nested params' do
      put admin_tag_path(tag.id, tag: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'update tag' do
    let(:tag) { Fabricate :tag, name: '#supertag' }

    it 'returns invalid when the schema does not match' do
      put admin_tag_path(tag.id, params: { tag: { trendable: true } })

      Admin::ActionLog.last.update(recorded_changes: { 'unallowed' => false })
      expect(Admin::ActionLog.last.recorded_changes).to_not match_json_schema('tags_format_1.0')
    end
  end
end
