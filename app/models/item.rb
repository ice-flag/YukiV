class Item < ActiveRecord::Base
  attr_accessible :reference_number,
  								# Item variables (string)
  								:asmeth, :bosal, :ets, :item_type, :walker, :ean,
  								# Item variables (decimal)
  								:price

 	has_many :products, :dependent => :destroy

 	# for CSV import
	def self.import(file)
	  CSV.foreach(file.path, headers: true) do |row|
	    item = find_by_asmeth(row["asmeth"]) || new
	    item.attributes = row.to_hash.slice(*accessible_attributes)
	    item.save!
	  end
	end

	# for quick search
	def self.search(query)
		# Postgres
		# where("reference_number ilike ? OR asmeth ilike ? OR bosal ilike ? OR walker ilike ? OR ets ilike ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
		# sqlite3
		where("reference_number like ? OR asmeth like ? OR bosal like ? OR walker like ? OR ets like ? OR ean like ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
	end

	# for asmet search
	def self.psearch(query)
		# Postgres
		# where("reference_number ilike ? OR asmeth ilike ? OR bosal ilike ? OR walker ilike ? OR ets ilike ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
		# sqlite3
		where("ean like ?", "%#{query}%")
	end
end