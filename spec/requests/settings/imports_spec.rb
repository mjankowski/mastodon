# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Imports' do
  describe 'POST /settings/imports' do
    let(:user) { Fabricate(:user) }

    before { sign_in user }

    it 'gracefully handles invalid nested params' do
      post settings_imports_path(form_import: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end
end
