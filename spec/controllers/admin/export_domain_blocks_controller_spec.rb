# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ExportDomainBlocksController do
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
    context 'with complete domain blocks CSV' do
      it 'renders page with expected domain blocks and returns http success' do
        post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks.csv') } }

        expect(mapped_batch_table_rows)
          .to contain_exactly(['bad.domain', :silence], ['worse.domain', :suspend], ['reject.media', :noop])
        expect(response)
          .to have_http_status(200)
      end
    end

    it 'handles bad data' do
      post :import, params: { admin_import: { data: fixture_file_upload('boop.mp3') } }

      expect(response)
        .to have_http_status(200)
      expect(response.body)
        .to include(I18n.t('admin.export_domain_blocks.new.title'))
    end

    context 'with a list of only domains' do
      it 'renders page with expected domain blocks and returns http success' do
        post :import, params: { admin_import: { data: fixture_file_upload('domain_blocks_list.txt') } }

        expect(mapped_batch_table_rows)
          .to contain_exactly(['bad.domain', :suspend], ['worse.domain', :suspend], ['reject.media', :suspend])
        expect(response)
          .to have_http_status(200)
      end
    end

    def mapped_batch_table_rows
      batch_table_rows.map { |row| [row.at_css('[id$=_domain]')['value'], row.at_css('[id$=_severity]')['value'].to_sym] }
    end

    def batch_table_rows
      response.parsed_body.css('body div.batch-table__row')
    end
  end

  it 'displays error on no file selected' do
    post :import, params: { admin_import: {} }

    expect(flash[:alert])
      .to eq(I18n.t('admin.export_domain_blocks.no_file'))
  end
end
