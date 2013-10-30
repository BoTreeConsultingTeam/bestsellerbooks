puts 'Saving websites to be crawled...'
["amazon", "crossword", "flipkart", "landmarkonthenet", "uread", "google", "homeshop18", "indiatimes"].each do |site|
	site_name = Site.where(name: site).first_or_initialize
	unless site_name.persisted?
		site_name.save
		puts "#{site_name.name}...is created"
	end
end
puts 'Websites saved....'

puts 'Saving book categories...'
["Biographies & Autobiographies", 'Business & Management', 	"Children", "Cooking", "Families & Relationships",
	"Health & Fitness", "Politics",	"History", "Indian Writing", "Literature", "Fiction", "Religion & Spirituality",
	"Skill Building & Learning", "Philosophy", "Education", "Humorous", "Sport", "Social & Science",
  "Action & Adventure"].each do |category|
	  book_category = BookCategory.where(category_name: category).first_or_initialize
	  unless book_category.persisted?
		  book_category.save
	  end
end
puts 'Book categories saved...'