class QuestionAnswersController < ApplicationController

  before_action :set_room
  before_action :set_question_answer, only: [:edit, :update]
  before_action :return_action

  def index
    if params[:study_count]
      if params[:study_count] == '5+'
        @question_answers = @room.question_answers.where("study_count >= ?", 5)
      else
        @question_answers = @room.question_answers.where(study_count: params[:study_count])
      end
    else
      @question_answers = @room.question_answers
    end
    count = @question_answers.count
    @random_question_answer = @question_answers.offset(rand(count)).first if count > 0
  end

  def new
    @question_answer = @room.question_answers.new
  end

  def create
    @question_answer = @room.question_answers.new(question_answer_params)
    @question_answer.study_count = 0
    if @question_answer.save
      redirect_to room_path(@room)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render 'new'
  end

  def update
    if params[:question_answer][:images_to_delete]
      params[:question_answer][:images_to_delete].each do |image_id|
        image = @question_answer.images.find(image_id)
        image.purge if image
      end
    end
    unless params[:question_answer][:images].reject(&:blank?).empty?
      @question_answer.images.attach(params[:question_answer][:images].reject(&:blank?))
    end
    updated_params = question_answer_params.except(:images, :images_to_delete)
    if @question_answer.update(updated_params)
      redirect_to room_path(@room)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def increment_study_count
    @random_question_answer = QuestionAnswer.find(params[:id])
    @random_question_answer.increment!(:study_count)
    redirect_to room_question_answer_path(@room, @random_question_answer)
  end

  def destroy
    question_answer = @room.question_answers.find(params[:id])
    question_answer.destroy
    redirect_to room_path(@room)
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_question_answer
    @question_answer = @room.question_answers.find(params[:id])
  end

  def question_answer_params
    params.require(:question_answer).permit(:question, :answer, :title, :study_count, :room_id, images: [], images_to_delete: [])
  end

  def return_action
    return unless current_user.id == @room.user_id
  end

end
