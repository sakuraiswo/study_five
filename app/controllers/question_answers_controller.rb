class QuestionAnswersController < ApplicationController

  include Searchable
  before_action :set_room
  before_action :set_question_answer, only: [:edit, :update]
  before_action :return_action

  def index
    @study_count_plus1 = (params[:study_count].to_i) + 1
    @question_answers = @room.question_answers

    if params[:study_count]
      if params[:study_count] == '10+'
        @question_answers = @question_answers.where("study_count >= ?", 10)
      elsif params[:study_count] == '5~9'
        @question_answers = @question_answers.where(study_count: 5..9)
      else
        @question_answers = @question_answers.where(study_count: params[:study_count])
      end
    end

    if session[:search_title].present?
      @question_answers = @question_answers.where(title: session[:search_title])
    end

    if session[:search_word].present?
      @question_answers = @question_answers.where("title LIKE :word OR question LIKE :word OR answer LIKE :word", word: "%#{session[:search_word]}%")
    end

    count = @question_answers.count
    @random_question_answer = @question_answers.offset(rand(count)).first if count > 0
  end

  def new
    @titles = @room.question_answers.select(:title).distinct.order(:title)
    @question_answer = @room.question_answers.new
  end

  def create
    @question_answer = @room.question_answers.new(question_answer_params)
    @question_answer.study_count = 0
    if @question_answer.save
      redirect_to room_path(@room, title: session[:search_title], word: session[:search_word])
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render 'new'
  end

  def update
    # 質問用の画像削除
    if params[:question_answer][:question_images_to_delete].present?
      params[:question_answer][:question_images_to_delete].each do |image_id|
        image = @question_answer.question_images.find(image_id)
        image.purge if image
      end
    end

    # 回答用の画像削除
    if params[:question_answer][:answer_images_to_delete].present?
      params[:question_answer][:answer_images_to_delete].each do |image_id|
        image = @question_answer.answer_images.find(image_id)
        image.purge if image
      end
    end

    # 質問用の新しい画像を追加
    unless params[:question_answer][:question_images].reject(&:blank?).empty?
      @question_answer.question_images.attach(params[:question_answer][:question_images].reject(&:blank?))
    end

    # 回答用の新しい画像を追加
    unless params[:question_answer][:answer_images].reject(&:blank?).empty?
      @question_answer.answer_images.attach(params[:question_answer][:answer_images].reject(&:blank?))
    end

    # パラメータの更新
    updated_params = question_answer_params.except(:question_images, :question_images_to_delete, :answer_images, :answer_images_to_delete)
    

    if @question_answer.update(updated_params)
      redirect_to room_path(@room, title: session[:search_title], word: session[:search_word])
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
    redirect_to room_path(@room, title: session[:search_title], word: session[:search_word])
  end

  private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def set_question_answer
    @question_answer = @room.question_answers.find(params[:id])
  end

  def question_answer_params
    params.require(:question_answer).permit(:question, :answer, :title, :study_count, :room_id, question_images: [], question_images_to_delete: [], answer_images: [], answer_images_to_delete: [])
  end

  def return_action
    return unless current_user.id == @room.user_id
  end

end
