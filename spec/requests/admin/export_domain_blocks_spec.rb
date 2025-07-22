# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Export Domain Blocks' do
  before { sign_in Fabricate(:admin_user) }

  describe 'POST /admin/export_domain_blocks/import' do
    it 'gracefully handles invalid nested params' do
      post import_admin_export_domain_blocks_path(admin_import: 'invalid')

      expect(response.body)
        .to include(I18n.t('admin.export_domain_blocks.no_file'))
    end
  end

  describe 'GET /admin/export_domain_blocks/export' do
    before do
      Fabricate(:domain_block, domain: 'bad.domain', severity: 'silence', public_comment: 'bad server')
      Fabricate(:domain_block, domain: 'worse.domain', severity: 'suspend', reject_media: true, reject_reports: true, public_comment: 'worse server', obfuscate: true)
      Fabricate(:domain_block, domain: 'reject.media', severity: 'noop', reject_media: true, public_comment: 'reject media and test unicode characters ♥')
      Fabricate(:domain_block, domain: 'no.op', severity: 'noop', public_comment: 'noop')
    end

    it 'renders instances' do
      get export_admin_export_domain_blocks_path(format: :csv)

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to eq(domain_blocks_csv_file)
    end

    def domain_blocks_csv_file
      File.read(File.join(file_fixture_path, 'domain_blocks.csv'))
    end
  end
end
