class QuestionAnswersController < ApplicationController

  before_action :set_room
  before_action :set_question_answer, only: [:edit, :update]

  def index
    @question_answers = @room.question_answers
  end

  def new
    @question_answer = @room.question_answers.new
  end

  def create
    @question_answer = @room.question_answers.new(question_answer_params)
    @question_answer.study_count = 0
    if @question_answer.save
      redirect_to room_question_answers_path(@room)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render 'new'
  end

  def update
    if @question_answer.update(question_answer_params)
      redirect_to room_question_answers_path(@room)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    question_answer = @room.question_answers.find(params[:id])
    question_answer.destroy
    redirect_to room_question_answers_path(@room)
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_question_answer
    @question_answer = @room.question_answers.find(params[:id])
  end

  def question_answer_params
    params.require(:question_answer).permit(:question, :answer, :study_count, :room_id)
  end


end
