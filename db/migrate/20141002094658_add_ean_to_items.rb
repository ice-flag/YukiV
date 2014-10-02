class AddEanToItems < ActiveRecord::Migration
  def change
    add_column :items, :ean, :string
  end
end
