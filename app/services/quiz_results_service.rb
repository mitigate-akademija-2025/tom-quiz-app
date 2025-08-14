class QuizResultsService
  require "rqrcode"

  def initialize(quiz, answers, score)
    @quiz = quiz
    @answers = answers
    @score = score
  end

  def generate_share_url
    # Compress JSON before encoding
    compressed = Zlib::Deflate.deflate(share_data.to_json)
    encoded_data = Base64.urlsafe_encode64(compressed)
    "https://TomTeraud.github.io/quiz-results/##{encoded_data}"
  end

  def generate_qr_code
    url = generate_share_url

    # Try different QR code sizes based on data length
    begin
      qr = if url.length > 2000
        # For very large data, only encode essential info
        compact_url = generate_compact_share_url
        RQRCode::QRCode.new(compact_url, level: :l, size: 10)
      else
        RQRCode::QRCode.new(url, level: :l)
      end

      qr.as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 4,
        standalone: true,
        use_path: true
      )
    rescue RQRCodeCore::QRCodeRunTimeError
      # Fallback to compact version if still too large
      qr = RQRCode::QRCode.new(generate_compact_share_url, level: :l)
      qr.as_svg(
        color: "000",
        shape_rendering: "crispEdges",
        module_size: 4,
        standalone: true,
        use_path: true
      )
    end
  end

  private

  def generate_compact_share_url
    # Only include wrong answers to reduce size
    compact_data = {
      quiz: @quiz.title[0..30], # Truncate title
      score: @score[:percentage],
      correct: @score[:correct],
      total: @score[:total],
      date: Date.today.strftime("%m/%d/%y"),
      wrong: generate_wrong_answers_only
    }

    compressed = Zlib::Deflate.deflate(compact_data.to_json)
    encoded_data = Base64.urlsafe_encode64(compressed)
    "https://TomTeraud.github.io/quiz-results/#c#{encoded_data}"
  end

  def generate_wrong_answers_only
    @quiz.questions.order(:id).filter_map.with_index do |question, index|
      user_answer_id = @answers[question.id.to_s]
      answers_array = question.answers.to_a
      user_answer = answers_array.find { |a| a.id.to_s == user_answer_id }
      correct_answer = answers_array.find(&:is_correct?)

      unless user_answer&.is_correct?
        {
          num: index + 1,
          q: question.question_text[0..50], # Truncate
          ua: user_answer&.answer_text || "Not answered",
          ca: correct_answer.answer_text
        }
      end
    end
  end

  private

  def share_data
    {
      quiz: @quiz.title,
      score: @score[:percentage],
      correct: @score[:correct],
      total: @score[:total],
      date: Date.today.strftime("%B %d, %Y"),
      details: generate_result_details
    }
  end

  def generate_result_details
    @quiz.questions.order(:id).map.with_index do |question, index|
      user_answer_id = @answers[question.id.to_s]
      answers_array = question.answers.to_a
      user_answer = answers_array.find { |a| a.id.to_s == user_answer_id }
      correct_answer = answers_array.find(&:is_correct?)

      {
        num: index + 1,
        question: question.question_text,
        user_answer: user_answer&.answer_text || "Not answered",
        correct_answer: correct_answer.answer_text,
        is_correct: user_answer&.is_correct? || false
      }
    end
  end
end
