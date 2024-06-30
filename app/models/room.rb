class Room < ApplicationRecord

  belongs_to :user
  has_many :question_answers, dependent: :destroy

  def has_low_study_count_question_answer?
    question_answers.where('study_count < ?', 5).exists?
  end

end
