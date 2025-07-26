# frozen_string_literal: true

class Mover::AccountNotes
  def initialize(source_account, target_account)
    @source_account = source_account
    @target_account = target_account
  end

  def move
    account_notes_targeting_source.find_each do |note|
      move_note(note)
    end
  end

  private

  def move_note(note)
    new_note = @target_account.targeted_account_notes.find_by(account: note.account)
    if new_note.nil?
      create_new_note(note)
    else
      new_note.update!(comment: [text_for(note.account), note.comment, "\n", new_note.comment].join("\n"))
    end
  rescue ActiveRecord::RecordInvalid
    nil
  end

  def create_new_note(note)
    begin
      create_target_account_note_for(note, [text_for(note.account), note.comment].join("\n"))
    rescue ActiveRecord::RecordInvalid
      create_target_account_note_for(note, note.comment)
    end
  end

  def create_target_account_note_for(note, comment)
    @target_account.targeted_account_notes.create!(account: note.account, comment:)
  end

  def account_notes_targeting_source
    @source_account.targeted_account_notes
  end

  def text_for(account)
    I18n.with_locale(account.user_locale.presence || I18n.default_locale) do
      I18n.t('move_handler.copy_account_note_text', acct: @source_account.acct)
    end
  end
end
