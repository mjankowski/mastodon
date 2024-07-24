# frozen_string_literal: true

class ChangeCanonicalEmailBlocksNullable < ActiveRecord::Migration[6.1]
  def change
    safety_assured { change_column_null :canonical_email_blocks, :reference_account_id, true }
  end
end
