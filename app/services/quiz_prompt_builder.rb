class QuizPromptBuilder
  def initialize(topic:, question_count:, language:)
    @topic = topic
    @question_count = question_count
    @language = language
  end

  def build
    <<~PROMPT
      Generate a quiz about "#{@topic}" in #{@language} language.

      Create exactly #{@question_count} multiple choice questions.
      Each question should have exactly 4 answer options.
      Only one answer should be marked as correct.

      Make the questions challenging and educational.
    PROMPT
  end
end
