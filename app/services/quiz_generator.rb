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

    response = chat.ask(prompt)
    quiz_data = parse_llm_response(response)
    create_quiz(quiz_data)
  end

  private

# app/services/quiz_generator.rb
private

  def parse_llm_response(response)
    content = response.content

    # Try to extract JSON from markdown code blocks
    # Handles: ```json\n{...}\n```
    json_string = if content.match?(/```(?:json)?\s*\n(.*?)\n```/m)
      content.match(/```(?:json)?\s*\n(.*?)\n```/m)[1]
    # Or just find JSON object in the text
    elsif content.match?(/(\{.*\})/m)
      content.match(/(\{.*\})/m)[1]
    else
      content
    end

    # Clean up common issues
    json_string = json_string.strip

    # Parse the cleaned JSON
    JSON.parse(json_string)
  rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse LLM response: #{e.message}"
    Rails.logger.error "Content was: #{content}"
    raise "Invalid LLM response format"
  end

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
            is_correct: a_data["is_correct"] || a_data["correct"]
          )
        end
      end

      quiz
    end
  end
end
