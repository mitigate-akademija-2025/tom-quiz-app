class AnswersController < ApplicationController
  before_action :set_quiz
  before_action :set_question
  before_action :set_answer, only: [ :edit, :update, :destroy ]

  def create
    @answer = @question.answers.build(answer_params)

    if @answer.save
      redirect_to quiz_question_path(@quiz, @question), notice: "Answer was successfully added.", status: :see_other
    else
      redirect_to quiz_question_path(@quiz, @question), alert: @answer.errors.full_messages.join(", "), status: :see_other
    end
  end

  private

  def set_quiz
    @quiz = Quiz.find(params[:quiz_id])
  end

  def set_question
    @question = @quiz.questions.find(params[:question_id])
  end

  def set_answer
    @answer = @question.answers.find(params[:id])
  end

  def answer_params
    params.expect(answer: [ :answer_text, :is_correct ])
  end
end
