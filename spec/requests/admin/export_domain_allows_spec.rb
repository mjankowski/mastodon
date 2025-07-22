# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Export Domain Allows' do
  before { sign_in Fabricate(:admin_user) }

  describe 'POST /admin/export_domain_allows/import' do
    it 'gracefully handles invalid nested params' do
      post import_admin_export_domain_allows_path(admin_import: 'invalid')

      expect(response)
        .to redirect_to(admin_instances_path)
    end
  end

  describe 'GET /admin/export_domain_allows/export' do
    before do
      Fabricate(:domain_allow, domain: 'good.domain')
      Fabricate(:domain_allow, domain: 'better.domain')
    end

    it 'renders instances' do
      get export_admin_export_domain_allows_path(format: :csv)

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to eq(domain_allows_csv_file)
    end
  end

  private

  def domain_allows_csv_file
    File.read(File.join(file_fixture_path, 'domain_allows.csv'))
  end
end
