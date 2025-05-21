# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account notes', :inline_jobs, :js, :streaming do
  include ProfileStories

  let(:email)               { 'test@example.com' }
  let(:password)            { 'password' }
  let(:confirmed_at)        { Time.zone.now }
  let(:finished_onboarding) { true }
  let(:note_text) { 'This is a personal note' }

  let!(:other_account) { Fabricate(:account) }

  before { as_a_logged_in_user }

  it 'can be written and viewed' do
    visit_profile(other_account)

    # Locate the note input, fill in text, use ctrl+enter to submit
    find_field(class: 'account__header__account-note__content')
      .click
      .fill_in(with: note_text)
      .send_keys([:control, :enter])

    expect(page)
      .to have_css('.account__header__account-note__content', text: note_text)

    # Navigate back and forth and ensure the comment is still here
    visit root_url
    visit_profile(other_account)

    # Verify record persisted
    expect(relevant_account_note.comment)
      .to eq(note_text)

    # Verify content still present on page
    expect(page)
      .to have_css('.account__header__account-note__content', text: note_text)
  end

  def visit_profile(account)
    visit short_account_path(account)

    expect(page)
      .to have_css('div.app-holder')
      .and have_css('form.compose-form')
  end

  def relevant_account_note
    AccountNote.find_by(account: bob.account, target_account: other_account)
  end
end
