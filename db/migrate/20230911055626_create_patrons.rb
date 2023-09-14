class CreatePatrons < ActiveRecord::Migration[7.0]
  def change
    create_table :patrons do |t|
      t.string :name
      t.integer :contact_information

      t.timestamps
    end
  end
end
