class Product < ActiveRecord::Base
  attr_accessible :item_id, :status,
  								# product attributes (boolean)
  								:active,
  								# product attributes (string)
  								:location

  belongs_to :item

  def status_output
  	if status == 1
  		"Label aangemaakt"
  	elsif status == 2
  		"In magazijn"
  	else
  		"Pizza"
  	end
  end

  # for scan warehouse_in search
  def self.search(query)
    find("#{query}")
  end
end