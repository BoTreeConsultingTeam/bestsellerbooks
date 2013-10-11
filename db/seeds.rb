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
	{category_name: "Business, Investing and Management"},
	{category_name: "Children"},
	{category_name: "Cooking, Food & Wine"},
	{category_name: "Families and Relationships"},
	{category_name: "Crafts & Hobbies"},
	{category_name: "Health and Fitness"},
	{category_name: "Home & Garden"},
	{category_name: "History and Politics"},
	{category_name: "Indian Writing"},
	{category_name: "Literature & Fiction"},
	{category_name: "Non-Fiction"},
	{category_name: "Religion & Spirituality"},
	{category_name: "Skill Building & Learning"},
	{category_name: "Philosophy"},
	{category_name: "Education"},
	{category_name: "History"},
	{category_name: "Humor"},
	{category_name: "Poetry"},
	{category_name: "Science"}
	])