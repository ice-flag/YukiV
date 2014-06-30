class Product < ActiveRecord::Base
  attr_accessible :item_id, :status

  belongs_to :item
end