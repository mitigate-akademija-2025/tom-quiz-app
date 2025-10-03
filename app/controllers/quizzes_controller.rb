class QuizzesController < ApplicationController
  allow_unauthenticated_access only: %i[ index take start answer results]
  before_action :set_quiz, only: [ :show, :start, :take, :answer, :results, :edit, :update, :destroy ]
  before_action :set_categories, only: [ :new, :edit, :create, :update ]
  before_action :authorize_owner!, only: [ :edit, :update, :destroy ]
  helper_method :llm_usage_available?

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
    selected_provider = params[:llm_provider].to_sym

    if current_user.free_user?
      # validation: daily usage limit
      unless LlmApiUsage.can_use?(current_user.email_address)
        time_left = LlmApiUsage.time_until_available(current_user.email_address)
        hours_left = (time_left / 3600.0).ceil
        return redirect_to generate_quizzes_path,
              alert: "Daily demo limit reached. Try again in #{hours_left} hours."
      end

      unless current_user.get_free_user_api_key_for(selected_provider)
        return redirect_to generate_quizzes_path,
              alert: "Demo not available for #{selected_provider}. Please select OpenAI or Gemini."
      end

      question_count = 5 # fixed for demo

    else

      unless current_user.find_user_api_key_for(selected_provider)
        return redirect_to generate_quizzes_path,
        alert: "No API key found for #{selected_provider}."
      end

      question_count = params[:question_count].to_i
    end

    service = QuizGenerator.new(
        user: current_user,
        topic: params[:topic],
        question_count: question_count,
        language: params[:language],
        provider: selected_provider,
        category_id: params[:category_id],
        author: params[:author]
      )

      begin
        @quiz = service.generate

        LlmApiUsage.record_usage!(current_user.email_address) if current_user.free_user?

        notice_text = current_user.free_user? ?
          "Demo quiz generated! (Limited to 5 questions)" :
          "Quiz generated successfully!"

        redirect_to @quiz, notice: notice_text
      rescue => e
        Rails.logger.error "Quiz generation failed: #{e.message}"
        redirect_to generate_quizzes_path, alert: "Quiz generation failed. Please try again."
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

  def llm_usage_available?
    LlmApiUsage.can_use?(current_user.email_address)
  end
end
