# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Settings Imports' do
  let(:user) { Fabricate(:user) }

  before { sign_in user }

  describe 'Importing custom filters from JSON' do
    let(:bulk_import) { user.account.bulk_imports.last }

    it 'uploads the file and schedules the confirmed import' do
      visit settings_imports_path
      expect(page)
        .to have_title(I18n.t('settings.import'))

      select I18n.t('imports.types.custom_filters'), from: 'form_import_type'
      choose 'form_import_mode_merge'
      attach_file 'form_import_data', file_fixture('custom_filters.json')

      expect { click_on I18n.t('imports.upload') }
        .to change(user.account.bulk_imports, :count).by(1)
      expect(bulk_import)
        .to have_attributes(state: 'unconfirmed', type: 'custom_filters', overwrite: false, original_filename: 'custom_filters.json')
      expect(page)
        .to have_current_path(settings_import_path(bulk_import))
        .and have_text('custom_filters.json')
        .and have_link(I18n.t('generic.confirm'))

      expect { click_on I18n.t('generic.confirm') }
        .to change { bulk_import.reload.state }.from('unconfirmed').to('scheduled')
        .and change(BulkImportWorker.jobs, :size).by(1)
      expect(page)
        .to have_title(I18n.t('settings.import'))
        .and have_text(I18n.t('imports.success'))
        .and have_text(I18n.t('imports.states.scheduled'))
    end
  end
end
