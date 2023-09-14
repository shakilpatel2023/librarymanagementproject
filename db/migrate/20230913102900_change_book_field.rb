class ChangeBookField < ActiveRecord::Migration[7.0]
  def change
    remove_column :books, :availability_status, :boolean
    add_column :books, :book_quantity, :integer
  end
end
