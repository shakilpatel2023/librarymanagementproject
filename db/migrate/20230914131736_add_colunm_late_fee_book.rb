class AddColunmLateFeeBook < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :late_fee, :integer
  end
end
