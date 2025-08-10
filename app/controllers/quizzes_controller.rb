class QuizzesController < ApplicationController
  def index
    @quizzes = Quiz.all
  end

  def show
    @quiz = Quiz.find(params[:id])
  end

  def new
    @quiz = Quiz.new
  end

  def create
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      redirect_to quiz_path(@quiz)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def quiz_params
    params.expect(quiz: [:title, :description])
  end

end
