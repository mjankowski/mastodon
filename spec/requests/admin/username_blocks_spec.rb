# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Username Blocks' do
  describe 'POST /admin/username_blocks' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post admin_username_blocks_path(username_block: 'invalid')

      expect(response)
        .to have_http_status(400)
    end
  end

  describe 'POST /admin/username_blocks/batch' do
    before { sign_in Fabricate(:admin_user) }

    it 'gracefully handles invalid nested params' do
      post batch_admin_username_blocks_path(form_username_block_batch: 'invalid')

      expect(response)
        .to redirect_to(admin_username_blocks_path)
    end
  end
end
