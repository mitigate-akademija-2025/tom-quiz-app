class QuestionsController < ApplicationController
  before_action :set_quiz
  before_action :set_question, only: [ :show, :edit, :update, :destroy ]

  def new
  end

  def show
  end

  def create
    @question = @quiz.questions.build(question_params)

    if @question.save
      redirect_to @quiz, notice: "Question was successfully added.", status: :see_other
    else
      redirect_to @quiz, alert: @question.errors.full_messages.join(", "), status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
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
