# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
	Site.create!([{name: "amazon"},{name: "crossword"},{name: "flipkart"},{name: "infibeam"},{name: "landmarkonthenet"}])
	# Bookcategory_name.create!([{category_name: "Suspense"},{category_name: "Mystery"},{category_name: "Religious"},{category_name: "Management"},
	# 	{category_name: "Criminology"},{category_name: "Economics"},{category_name: "Fiction"},{category_name: "Historical"},
	# 	{category_name: "Vocabulary"},{category_name: "Fantasy"},{category_name: "Cultural"}])
	# {category_name: ""},
	BookCategory.create!([
	{category_name: "Biographies & Autobiographies"},
	{category_name: "business & Management"},
	{category_name: "Children"},
	{category_name: "Cooking"},
	{category_name: "Families & Relationships"},
	{category_name: "Health & Fitness"},
	{category_name: "Politics"},
	{category_name: "History"},
	{category_name: "Indian Writing"},
	{category_name: "Literature"},
	{category_name: "Fiction"},
	{category_name: "Religion & Spirituality"},
	{category_name: "Skill Building & Learning"},
	{category_name: "Philosophy"},
	{category_name: "Education"},
	{category_name: "Humorous"},
	{category_name: "Social & Science"},
	{category_name: "Action & Adventure"}
	])