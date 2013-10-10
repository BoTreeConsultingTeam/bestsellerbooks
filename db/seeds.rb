# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
	Site.create!([{name: "amazon"},{name: "crossword"},{name: "flipkart"},{name: "infibeam"},{name: "landmarkonthenet"}])
	BookCategory.create!([{category: "Suspense"},{category: "Mystery"},{category: "Religious"},{category: "Management"},
		{category: "Criminology"},{category: "Economics"},{category: "Fiction"},{category: "Historical"},
		{category: "Vocabulary"},{category: "Fantasy"},{category: "Cultural"}])
	# {category: ""},