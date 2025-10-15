KeyType.find_or_create_by(name: "openai")
KeyType.find_or_create_by(name: "gemini")
puts "Created #{KeyType.count} key types"

categories = [
 "Science",
 "History",
 "Culture",
 "Sports",
 "Technology",
 "General Knowledge",
 "Mathematics",
 "Literature"
]

categories.each do |name|
 Category.find_or_create_by(name: name) do |category|
   category.description = "#{name} related quizzes"
 end
end
