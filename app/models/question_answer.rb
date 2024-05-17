class QuestionAnswer < ApplicationRecord

  validates :study_count, presence: true

  belongs_to :room
  has_many_attached :images



end
