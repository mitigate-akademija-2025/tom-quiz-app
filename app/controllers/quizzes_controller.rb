class QuizzesController < ApplicationController
  allow_unauthenticated_access only: %i[ index take start answer results]
  before_action :set_quiz, only: [ :show, :start, :take, :answer, :results, :edit, :update, :destroy ]
  before_action :set_categories, only: [ :new, :edit, :create, :update ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]

  def index
    @quizzes = Quiz.all
  end

  def show
    # @quiz already set by before_action
  end

  def new
    @quiz = Quiz.new
    # @categories already set by before_action
  end

  def create
    @quiz = current_user.quizzes.build(quiz_params)
    if @quiz.save
      redirect_to @quiz, notice: "Quiz was successfully created.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    # @quiz and @categories already set by before_action
  end

  def update
    if @quiz.update(quiz_params)
      redirect_to @quiz, notice: "Quiz was successfully updated.", status: :see_other
    else
      # @categories already loaded by before_action
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @quiz.destroy!
    redirect_to quizzes_path, notice: "Quiz was successfully deleted.", status: :see_other
  end

  def start
    # @quiz already set by before_action
    session[:quiz_attempt] = {
      "answers" => {},
      "started_at" => Time.current
    }
  end

  def take
    @current_question_number = params[:question]&.to_i || 1
    @questions = @quiz.questions.order(:id)  # Or order(:position) if you have that column
    @question = @questions[@current_question_number - 1]
    @total_questions = @questions.count

    if @question.nil?
      redirect_to quiz_path(@quiz), alert: "Question not found"
      return
    end

    # Check for existing answer
    @selected_answer = session.dig(:quiz_attempt, "answers", @question.id.to_s)
  end

  def answer
    session[:quiz_attempt] ||= { "answers" => {} }
    session[:quiz_attempt]["answers"][params[:question_id]] = params[:answer_ids]

    next_position = params[:question].to_i + 1

    if next_position <= @quiz.questions.count
      redirect_to take_quiz_path(@quiz, question: next_position)
    else
      redirect_to results_quiz_path(@quiz)
    end
  end

  def results
    @quiz = Quiz.includes(questions: :answers).find(params[:id])
    @answers = session.dig(:quiz_attempt, "answers") || {}
    @score = calculate_score(@quiz, @answers)

    # Generate QR code and share URL
    results_service = QuizResultsService.new(@quiz, @answers, @score)
    @qr_svg = results_service.generate_qr_code
    @share_url = results_service.generate_share_url

    # Store best score
    session[:best_scores] ||= {}
    current_best = session[:best_scores][@quiz.id.to_s] || 0
    session[:best_scores][@quiz.id.to_s] = [ @score[:percentage], current_best ].max

    session[:quiz_attempt] = nil
  end


  def generate
    # Show form
  end

  def create_from_ai
    service = QuizGeneratorService.new(
      topic: params[:topic],
      question_count: params[:question_count].to_i,
      category_id: params[:category_id],
      language: params[:language],
      llm_provider: params[:llm_provider],
      author: params[:author],
      user_id: current_user.id,
      api_key: current_user.api_keys.for_key_type(params[:llm_provider]).first&.key
    )

    @quiz = service.generate

    if @quiz
      redirect_to @quiz, notice: "Quiz generated successfully!"
    else
      redirect_to generate_quizzes_path, alert: "Failed to generate quiz"
    end
  end

  def create_from_demo
    unless LlmApiUsage.can_use?(current_user.email_address)
      time_left = LlmApiUsage.time_until_available(current_user.email_address)
      hours_left = (time_left / 3600.0).ceil
      return redirect_to generate_quizzes_path,
            alert: "Daily demo limit reached. Try again in #{hours_left} hours."
    end

    # Get demo API keys from credentials
    demo_keys = Rails.application.credentials.llm_api_keys
    selected_provider = params[:llm_provider].to_sym
    demo_api_key = demo_keys[selected_provider]

    # Check if there is a demo key for user selected provider
    unless demo_api_key
      return redirect_to generate_quizzes_path,
            alert: "Demo not available for #{params[:llm_provider]}. Please select OpenAI or Gemini."
    end

    service = QuizGeneratorService.new(
      topic: params[:topic],
      question_count: [ params[:question_count].to_i, 5 ].min, # Max 5 for demo
      category_id: params[:category_id],
      language: params[:language],
      llm_provider: params[:llm_provider],
      author: params[:author],
      user_id: current_user.id,
      api_key: demo_api_key
    )

    begin
      @quiz = service.generate
      if @quiz
        LlmApiUsage.record_usage!(current_user.email_address)
        redirect_to @quiz, notice: "Demo quiz generated with #{params[:llm_provider]}! (Limited to 5 questions)"
      else
        redirect_to generate_quizzes_path, alert: "Failed to generate demo quiz"
      end
    rescue => e
      Rails.logger.error "Demo generation failed: #{e.message}"
      redirect_to generate_quizzes_path, alert: "Demo generation failed. Please try again."
    end
  end

  private

  # For public actions (show, start, take, answer, results)
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def authorize_owner!
    unless owner_of?(@quiz)
      redirect_to quizzes_path, alert: "Not authorized"
    end
  end

  def set_categories
    @categories = Category.all.order(:name)
  end

  def quiz_params
    params.expect(quiz: [ :title, :description, :category_id, :language, :author ])
  end

  def calculate_score(quiz, answers)
    correct = 0
    total = quiz.questions.count

    quiz.questions.each do |question|
      user_answer_id = answers[question.id.to_s]
      if user_answer_id && question.answers.find_by(id: user_answer_id)&.is_correct?
        correct += 1
      end
    end

    {
      correct: correct,
      total: total,
      percentage: total > 0 ? (correct.to_f / total * 100).round : 0
    }
  end
end
