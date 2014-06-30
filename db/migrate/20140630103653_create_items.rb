class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :reference_number
      t.string :asmeth
      t.decimal :price
      t.string :item_type
      t.string :bosal
      t.string :walker
      t.string :ets

      t.timestamps
    end
  end
end
