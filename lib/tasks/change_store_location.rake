desc "Change of storage location"
task :change_store_location => :environment do
	Product.all.each do |product|
		new_location = product.location.to_s.gsub("I","J").gsub("i","J")
			Product.update(product.id, location: new_location)
	end
end