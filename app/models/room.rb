class Room < ApplicationRecord

  belongs_to :user
  has_many :question_answers, dependent: :destroy

end
