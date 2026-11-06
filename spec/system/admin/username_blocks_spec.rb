# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Username Blocks' do
  let(:admin) { Fabricate(:admin_user) }

  before { sign_in admin }

  describe 'Creating username blocks' do
    let!(:username_block) { Fabricate :username_block }

    it 'lists existing blocks and creates a new block' do
      visit admin_username_blocks_path
      expect(page)
        .to have_title(I18n.t('admin.username_blocks.title'))
        .and have_text(username_block.username)

      click_on I18n.t('admin.username_blocks.add_new')
      expect(page)
        .to have_title(I18n.t('admin.username_blocks.new.title'))

      fill_in 'username_block_username', with: 'banana'
      select I18n.t('admin.username_blocks.comparison.contains'), from: 'username_block_comparison'
      uncheck 'username_block_allow_with_approval'

      expect { click_on I18n.t('admin.username_blocks.new.create') }
        .to change(UsernameBlock.where(username: 'banana', exact: false, allow_with_approval: false), :count).by(1)
      expect(page)
        .to have_title(I18n.t('admin.username_blocks.title'))
        .and have_text(I18n.t('admin.username_blocks.created_msg'))
        .and have_text('banana')
    end
  end

  describe 'Editing username blocks' do
    let!(:username_block) { Fabricate :username_block, username: 'banana' }

    it 'updates an existing block' do
      visit admin_username_blocks_path
      click_on username_block.username
      expect(page)
        .to have_title(I18n.t('admin.username_blocks.edit.title'))

      fill_in 'username_block_username', with: 'bebebe'

      expect { click_on I18n.t('generic.save_changes') }
        .to change { username_block.reload.username }.from('banana').to('bebebe')
      expect(page)
        .to have_title(I18n.t('admin.username_blocks.title'))
        .and have_text(I18n.t('admin.username_blocks.updated_msg'))
        .and have_text('bebebe')
        .and have_no_text('banana')
    end
  end

  describe 'Performing batch updates' do
    let!(:username_blocks) { Fabricate.times(2, :username_block) }
    let!(:unselected_block) { Fabricate :username_block }

    it 'deletes selected blocks and preserves unselected blocks' do
      visit admin_username_blocks_path

      username_blocks.each do |username_block|
        within '.batch-table__row', text: username_block.username do
          find_field(type: 'checkbox').check
        end
      end

      expect { click_on I18n.t('admin.username_blocks.delete') }
        .to change(UsernameBlock.where(id: username_blocks.map(&:id)), :count).from(2).to(0)
      expect(unselected_block.reload)
        .to be_persisted
      expect(page)
        .to have_title(I18n.t('admin.username_blocks.title'))
        .and have_text(unselected_block.username)

      username_blocks.each do |username_block|
        expect(page)
          .to have_no_text(username_block.username)
      end
    end
  end
end
