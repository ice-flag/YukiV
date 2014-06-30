class Item < ActiveRecord::Base
  attr_accessible :reference_number,
  								# Item variables (string)
  								:asmeth, :bosal, :ets, :item_type, :walker,
  								# Item variables (decimal)
  								:price

 	has_many :products, :dependent => :destroy

 	# for CSV import
	def self.import(file)
	  CSV.foreach(file.path, headers: true) do |row|
	    item = find_by_id(row["reference_number"]) || new
	    item.attributes = row.to_hash.slice(*accessible_attributes)
	    item.save!
	  end
	end

	# for quick search
	def self.search(query)
		# Postgres
		# where("reference_number ilike ? OR asmeth ilike ? OR bosal ilike ? OR walker ilike ? OR ets ilike ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
		# sqlite3
		where("reference_number like ? OR asmeth like ? OR bosal like ? OR walker like ? OR ets like ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
	end
end