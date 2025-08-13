class QuizzesController < ApplicationController
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy, :start, :take, :answer, :results ]
  before_action :set_categories, only: [ :new, :edit, :create, :update ]

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
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      redirect_to @quiz, notice: "Quiz was successfully created.", status: :see_other
    else
      # @categories already loaded by before_action
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
    @quiz.destroy
    redirect_to quizzes_path, notice: "Quiz was successfully deleted.", status: :see_other
  end

  def start
    session[:quiz_attempt] = {
      "answers" => {},
      "started_at" => Time.current
    }
    redirect_to take_quiz_path(@quiz, question: 1)
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
    
    Rails.logger.debug "=== TAKE ACTION ==="
    Rails.logger.debug "Question position: #{@current_question_number} of #{@total_questions}"
    Rails.logger.debug "Question ID: #{@question.id}"
    Rails.logger.debug "Existing answer: #{@selected_answer}"
  end

  def answer
    session[:quiz_attempt] ||= { "answers" => {} }
    session[:quiz_attempt]["answers"][params[:question_id]] = params[:answer_ids]
    
    Rails.logger.debug "=== ANSWER ACTION ==="
    Rails.logger.debug "Question ID: #{params[:question_id]}"
    Rails.logger.debug "Answer ID: #{params[:answer_ids]}"
    Rails.logger.debug "All answers so far: #{session[:quiz_attempt]["answers"]}"
    
    next_position = params[:question].to_i + 1
    
    if next_position <= @quiz.questions.count
      redirect_to take_quiz_path(@quiz, question: next_position)
    else
      redirect_to results_quiz_path(@quiz)
    end
  end

  def results
    # @quiz already set by before_action
    @answers = session.dig(:quiz_attempt, "answers") || {}
    @score = calculate_score(@quiz, @answers)

    # Store best score
    session[:best_scores] ||= {}
    current_best = session[:best_scores][@quiz.id.to_s] || 0
    session[:best_scores][@quiz.id.to_s] = [ @score[:percentage], current_best ].max

    # Clear the current attempt
    session[:quiz_attempt] = nil
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

  def set_categories
    @categories = Category.all.order(:name)
  end

  def quiz_params
    params.expect(quiz: [ :title, :description, :category_id ])
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
