class RoomsController < ApplicationController

  include Searchable
  before_action :set_room, only: [:edit, :update, :show]
  before_action :return_action, only: [:edit, :update, :show]

  def index
    @rooms = Room.all.includes(:question_answers)
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
      session[:search_title] = params[:title]
    else
      session.delete(:search_title)
    end

    if params[:word].present?
      session[:search_word] = params[:word]
    else
      session.delete(:search_word)
    end

    @question_answers = search_question_answers(@room.question_answers.order(study_count: :asc))
    @titles = @room.question_answers.select(:title).distinct.order(:title)
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
