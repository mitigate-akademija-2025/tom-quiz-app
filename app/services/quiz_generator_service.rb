class QuizGeneratorService
  def initialize(topic:, question_count: 10, category_id: nil)
    @topic = topic
    @question_count = question_count
    @category_id = category_id
  end

  def generate
    # Get questions from LLM
    response = fetch_from_llm(build_prompt)

    # Parse LLM response
    quiz_data = parse_llm_response(response)

    # Create quiz in database
    create_quiz(quiz_data)
  end

  private

  def build_prompt
    <<~PROMPT
    Generate a #{@question_count}-question quiz about #{@topic}.
        Mix difficulty levels randomly.
    
        Return as JSON:
        {
        "title": "Quiz title",
        "description": "Brief description",
        "questions": [
            {
            "question_text": "Question here?",
            "difficulty": 1-3 (1=easy, 2=medium, 3=hard),
            "answers": [
                {"text": "Answer 1", "correct": false},
                {"text": "Answer 2", "correct": true},
                {"text": "Answer 3", "correct": false},
                {"text": "Answer 4", "correct": false}
            ]
            }
        ]
        }
    PROMPT
  end

  def fetch_from_llm(prompt)
    client = LlmClient.new
    client.generate(prompt)
  end

def parse_llm_response(response)
    Rails.logger.debug "LLM Response: #{response}"

    json_match = response.match(/\{.*\}/m)
    return nil unless json_match

    parsed = JSON.parse(json_match[0])
    Rails.logger.debug "Parsed JSON: #{parsed}"
    parsed
    rescue JSON::ParserError => e
    Rails.logger.error "Failed to parse: #{e.message}"
    Rails.logger.error "Response was: #{response}"
    nil
    end

def create_quiz(data)
  return nil unless data

  ActiveRecord::Base.transaction do
    quiz = Quiz.create!(
      title: data["title"],
      description: data["description"],
      category_id: @category_id
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
          is_correct: a_data["correct"]
        )
      end
    end

    quiz
  end
end
end
