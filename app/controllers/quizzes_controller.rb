class QuizzesController < ApplicationController
  before_action :set_quiz, only: [ :show, :edit, :update, :destroy ]
  before_action :set_categories, only: [ :new, :edit ]

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
      set_categories  # Reload categories for form
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
      set_categories  # Reload categories for form
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @quiz.destroy
    redirect_to quizzes_path, notice: "Quiz was successfully deleted.", status: :see_other
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
end
