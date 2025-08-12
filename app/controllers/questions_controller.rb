class QuestionsController < ApplicationController
  before_action :set_quiz
  before_action :set_question, only: [ :show, :edit, :update, :destroy ]

  def new
    @question = @quiz.questions.build
  end

  def show
    # @question already set by before_action
  end

  def create
    @question = @quiz.questions.build(question_params)

    if @question.save
      redirect_to @quiz, notice: "Question was successfully added.", status: :see_other
    else
      redirect_to @quiz, alert: @question.errors.full_messages.join(", "), status: :see_other
    end
  end

  def edit
    # @question already set by before_action
  end

  def update
    if @question.update(question_params)
      redirect_to @quiz, notice: "Question was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @question.destroy
    redirect_to @quiz, notice: "Question was successfully deleted.", status: :see_other
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def set_question
    @question = @quiz.questions.find(params[:id])
  end

  def question_params
    params.expect(question: [ :question_text, :question_type ])
  end
end
