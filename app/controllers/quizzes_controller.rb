class QuizzesController < ApplicationController
  def index
    @quizzes = Quiz.all
  end

  def show
    @quiz = Quiz.find(params[:id])
  end

  def new
    @quiz = Quiz.new
    @categories = Category.all.order(:name)
  end

  def create
    @quiz = Quiz.new(quiz_params)

    if @quiz.save
      flash[:notice] = "New quiz created!"
      redirect_to quiz_path(@quiz)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @quiz = Quiz.find(params[:id])
    @categories = Category.all.order(:name)
  end

  def update
    @quiz = Quiz.find(params[:id])

    if @quiz.update(quiz_params)
      flash[:notice] = "Quiz Updated!!"
      redirect_to quiz_path(@quiz)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quiz = Quiz.find(params[:id])

    @quiz.destroy
    flash[:notice] = "Quiz deleted!"
    redirect_to quizzes_path
  end

  def quiz_params
    params.expect(quiz: [ :title, :description, :difficulty, :category_id ])
  end
end
