# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExportDomainAllowsController do
  render_views

  before { sign_in Fabricate(:admin_user) }

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response)
        .to have_http_status(200)
    end
  end

  describe 'POST #import' do
    it 'allows imported domains' do
      post :import, params: { admin_import: { data: fixture_file_upload('domain_allows.csv') } }

      expect(response)
        .to redirect_to(admin_instances_path)

      # Header row should not be imported, but domains should
      expect(DomainAllow)
        .to_not exist(domain: '#domain')
      expect(DomainAllow)
        .to exist(domain: 'good.domain')
        .and exist(domain: 'better.domain')
    end

    it 'handles bad data' do
      post :import, params: { admin_import: { data: fixture_file_upload('boop.mp3') } }

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to include(I18n.t('admin.export_domain_allows.new.title'))
    end

    it 'displays error on no file selected' do
      post :import, params: { admin_import: {} }

      expect(response)
        .to redirect_to(admin_instances_path)
      expect(flash[:error])
        .to eq(I18n.t('admin.export_domain_allows.no_file'))
    end
  end
end
