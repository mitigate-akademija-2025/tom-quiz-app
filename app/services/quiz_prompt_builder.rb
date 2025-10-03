class QuizPromptBuilder
  def initialize(topic:, question_count:, language:)
    @topic = topic
    @question_count = question_count
    @language = language
  end

  def build
    <<~PROMPT

      Generate a #{@question_count}-question quiz about #{@topic} in #{@language.capitalize}.
      Mix difficulty levels randomly.
      Do not mix in any other language. Every field (title, description, questions, answers) must be written in #{@language.capitalize}.

      CRITICAL: Return ONLY valid JSON. No markdown, no code blocks, no explanations.
      Do not wrap the JSON in ```json``` or any other formatting.
      Start your response with { and end with }

      Return the result as JSON in this exact format:
      {
        "title": "Creative quiz title",
        "description": "Engaging 2-3 sentence description that explains what participants will learn and why this quiz is interesting",
        "questions": [
          {
            "question_text": "Question here?",
            "difficulty": <integer between 1 and 3>

            "answers": [
              {"text": "Answer 1", "correct": false},
              {"text": "Answer 2", "correct": true},
              {"text": "Answer 3", "correct": false},
              {"text": "Answer 4", "correct": false}
            ]
          }
        ]
      }
      Return ONLY the JSON, nothing else.
    PROMPT
  end
end
