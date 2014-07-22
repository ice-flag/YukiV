desc "Change of storage location"
task :change_store_location => :environment do
	Product.all.each do |product|
		new_location = product.location.to_s.gsub("E3","E1").gsub("H2","H3")
			Product.update(product.id, location: new_location)
	end
end