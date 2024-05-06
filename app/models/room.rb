class Room < ApplicationRecord

  has_many :question_answers, dependent: :destroy

end
