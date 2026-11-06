# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Tags' do
  describe 'Tag interaction' do
    let!(:tag) { Fabricate(:tag, name: 'test', usable: true, trendable: false, listable: true) }

    before { sign_in Fabricate(:admin_user) }

    it 'allows tags listing and editing' do
      visit admin_tags_path

      expect(page)
        .to have_title(I18n.t('admin.tags.title'))

      click_on '#test'

      fill_in display_name_field, with: 'NewTagName'
      expect { click_on submit_button }
        .to_not(change { tag.reload.display_name })
      expect(page)
        .to have_text(match_error_text)

      fill_in display_name_field, with: 'TEST'
      expect { click_on submit_button }
        .to(change { tag.reload.display_name }.to('TEST'))
    end

    it 'updates tag statuses and records the changes in the audit log' do
      visit admin_tags_path
      click_on '#test'

      check 'tag_trendable'
      uncheck 'tag_listable'

      expect { click_on submit_button }
        .to change(Admin::ActionLog, :count).by(1)
      expect(tag.reload)
        .to have_attributes(usable: true, trendable: true, listable: false)
      expect(page)
        .to have_title(tag.formatted_name)
        .and have_text(I18n.t('admin.tags.updated_msg'))
      expect(Admin::ActionLog.last.recorded_changes)
        .to eq('listable' => false, 'trendable' => true)
        .and match_json_schema('tags_format_1.0')
    end

    def display_name_field
      form_label('defaults.display_name')
    end

    def match_error_text
      I18n.t('tags.does_not_match_previous_name')
    end
  end
end
