class Item < ActiveRecord::Base
  attr_accessible :reference_number,
  								# Item variables (string)
  								:asmeth, :bosal, :ets, :item_type, :walker,
  								# Item variables (decimal)
  								:price

 	has_many :products, :dependent => :destroy

	def self.import(file)
	  CSV.foreach(file.path, headers: true) do |row|
	    item = find_by_id(row["reference_number"]) || new
	    item.attributes = row.to_hash.slice(*accessible_attributes)
	    item.save!
	  end
	end
end