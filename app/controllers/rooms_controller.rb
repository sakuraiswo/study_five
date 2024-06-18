class RoomsController < ApplicationController

  before_action :set_room, only: [:edit, :update, :show]
  before_action :return_action, only: [:edit, :update, :show]

  def index
    @rooms = Room.all
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new(room_params)
    if @room.save
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render 'new'
  end

  def update
    if @room.update(room_params)
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    room = Room.find(params[:id])
    return unless current_user.id == room.user_id
    room.destroy
    redirect_to root_path
  end

  def show
    if params[:title].present?
      @question_answers = @room.question_answers.where(title: params[:title]).order(study_count: :asc)
    else
      @question_answers = @room.question_answers.order(study_count: :asc)
    end

    @titles = @room.question_answers.select(:title).distinct
    question_count
  end


  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(:room_name, :room_number).merge(user_id: current_user.id)
  end

  def question_count
    @study_counts = @question_answers.group(:study_count).count
  end

  def return_action
    return unless current_user.id == @room.user_id
  end

end
