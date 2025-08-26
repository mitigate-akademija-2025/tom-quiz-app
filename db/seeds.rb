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

puts "Created #{Category.count} categories"

# Create users
user1 = User.create!(email_address: "tom@quizapp.lv", password: "123")
user2 = User.create!(email_address: "test@test.lv", password: "123")

# Create quiz for user1
quiz1 = user1.quizzes.create!(
 title: "Basic Science Quiz",
 description: "Test your knowledge of general science",
 category: Category.find_by(name: "Science"),
 author: "Tom"
)

# Add questions to quiz1
q1 = quiz1.questions.create!(
 question_text: "What is the chemical symbol for water?",
 question_type: "multiple_choice",
 difficulty: 1
)
q1.answers.create!([
 { answer_text: "H2O", is_correct: true },
 { answer_text: "CO2", is_correct: false },
 { answer_text: "O2", is_correct: false },
 { answer_text: "NaCl", is_correct: false }
])

q2 = quiz1.questions.create!(
 question_text: "How many planets are in our solar system?",
 question_type: "multiple_choice",
 difficulty: 1
)
q2.answers.create!([
 { answer_text: "7", is_correct: false },
 { answer_text: "8", is_correct: true },
 { answer_text: "9", is_correct: false },
 { answer_text: "10", is_correct: false }
])

# Create quiz for user2
quiz2 = user2.quizzes.create!(
 title: "World History Basics",
 description: "Essential historical facts everyone should know",
 category: Category.find_by(name: "History"),
 author: "Test User"
)

# Add questions to quiz2
q3 = quiz2.questions.create!(
 question_text: "In which year did World War II end?",
 question_type: "multiple_choice",
 difficulty: 2
)
q3.answers.create!([
 { answer_text: "1943", is_correct: false },
 { answer_text: "1944", is_correct: false },
 { answer_text: "1945", is_correct: true },
 { answer_text: "1946", is_correct: false }
])

q4 = quiz2.questions.create!(
 question_text: "Who was the first president of the United States?",
 question_type: "multiple_choice",
 difficulty: 1
)
q4.answers.create!([
 { answer_text: "Thomas Jefferson", is_correct: false },
 { answer_text: "George Washington", is_correct: true },
 { answer_text: "John Adams", is_correct: false },
 { answer_text: "Benjamin Franklin", is_correct: false }
])

puts "Created #{User.count} users"
puts "Created #{Quiz.count} quizzes"
puts "Created #{Question.count} questions"
puts "Created #{Answer.count} answers"
