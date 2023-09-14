class RemoveAvailabilityStatusFromBook < ActiveRecord::Migration[7.0]
  def change
    remove_column :books, :availability_status
  end
end
