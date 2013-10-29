[{ name: "amazon" },
	{ name: "crossword" },
	{ name: "flipkart" },
	{ name: "landmarkonthenet" },
	{ name: "uread" },
	{ name: "google" },
	{ name: "homeshop18" },
	{ name: "indiatimes" }].map do |site|
	site_name = Site.where(site).first_or_initialize
	unless site_name.persisted?
		site_name.save
		puts "#{site_name.name}...is created"
	end
end

[{ category_name: "Biographies & Autobiographies" },
	{ category_name: "Business & Management" },
	{ category_name: "Children" },
	{ category_name: "Cooking" },
	{ category_name: "Families & Relationships" },
	{ category_name: "Health & Fitness" },
	{ category_name: "Politics" },
	{ category_name: "History" },
	{ category_name: "Indian Writing" },
	{ category_name: "Literature" },
	{ category_name: "Fiction" },
	{ category_name: "Religion & Spirituality" },
	{ category_name: "Skill Building & Learning" },
	{ category_name: "Philosophy" },
	{ category_name: "Education" },
	{ category_name: "Humorous" },
	{ category_name: "Sport" },
	{ category_name: "Social & Science" },
	{ category_name: "Action & Adventure" }].map do |category|
	category_name = BookCategory.where(category).first_or_initialize
	unless category_name.persisted?
		category_name.save
		puts "#{category_name.name}...is created"
	end
end
