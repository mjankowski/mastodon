class DropAnnualReports < ActiveRecord::Migration[7.1]
  def up
    drop_table :generated_annual_reports
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
