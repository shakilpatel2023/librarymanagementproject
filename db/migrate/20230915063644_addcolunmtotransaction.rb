class Addcolunmtotransaction < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :date_for_late_fee, :date
  end
end
