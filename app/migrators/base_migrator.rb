# frozen_string_literal: true

class BaseMigrator
  attr_reader :source_account, :target_account

  def initialize(source_account, target_account)
    @source_account = source_account
    @target_account = target_account
  end

  def self.call(source, target)
    new(source, target).call
  end

  def call
    raise 'Implement in migrator'
  end

  private

  def add_account_note_if_needed!(account, id)
    unless AccountNote.exists?(account: account, target_account: @target_account)
      text = I18n.with_locale(account.user&.locale.presence || I18n.default_locale) do
        I18n.t(id, acct: @source_account.acct)
      end
      AccountNote.create!(account: account, target_account: @target_account, comment: text)
    end
  end
end
