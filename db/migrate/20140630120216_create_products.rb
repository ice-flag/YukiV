class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :status

      t.timestamps
    end
  end
end
