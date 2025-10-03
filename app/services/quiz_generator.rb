# app/services/quiz_generator.rb
class QuizGenerator
  def initialize(user:, topic:, question_count:, language:, provider:, category_id: nil, author: nil)
    @user = user
    @topic = topic
    @question_count = question_count
    @language = language
    @provider = provider
    @category_id = category_id
    @author = author
  end

  def generate
    chat = @user.llm_chat(@provider)
    prompt = QuizPromptBuilder.new(
      topic: @topic,
      question_count: @question_count,
      language: @language
    ).build

    response = chat.with_schema(QuizSchema).ask(prompt)
    create_quiz(response.content)
  end

  private

private
  def create_quiz(data)
    return nil unless data

    ActiveRecord::Base.transaction do
      quiz = Quiz.create!(
        title: data["title"],
        description: data["description"],
        category_id: @category_id,
        language: @language,
        author: @author,
        user: @user
      )

      data["questions"].each do |q_data|
        question = quiz.questions.create!(
          question_text: q_data["question_text"],
          question_type: "multiple_choice",
          difficulty: q_data["difficulty"] || 1
        )

        q_data["answers"].each do |a_data|
          question.answers.create!(
            answer_text: a_data["text"],
            is_correct: a_data["is_correct"]
          )
        end
      end

      quiz
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create quiz: #{e.message}"
    raise "Failed to save quiz: #{e.message}"
  end
end
