# frozen_string_literal: true

class AccountNoteMigrator < BaseMigrator
  def call
    source_account_notes.find_each do |note|
      new_note = AccountNote.find_by(account: note.account, target_account: @target_account)
      if new_note.nil?
        create_new_note(note)
      else
        new_note.update!(comment: [copy_note_text(note), note.comment, "\n", new_note.comment].join("\n"))
      end
    rescue ActiveRecord::RecordInvalid
      nil
    end
  end

  private

  def create_new_note(note)
    begin
      AccountNote.create!(account: note.account, target_account: @target_account, comment: [copy_note_text(note), note.comment].join("\n"))
    rescue ActiveRecord::RecordInvalid
      AccountNote.create!(account: note.account, target_account: @target_account, comment: note.comment)
    end
  end

  def copy_note_text(note)
    I18n.with_locale(note.account.user&.locale.presence || I18n.default_locale) do
      I18n.t('move_handler.copy_account_note_text', acct: @source_account.acct)
    end
  end

  def source_account_notes
    AccountNote
      .where(target_account: @source_account)
  end
end
