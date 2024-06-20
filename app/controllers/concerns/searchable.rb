module Searchable
  extend ActiveSupport::Concern

  included do
    def search_question_answers(scope)
      if params[:title].present?
        scope = scope.where(title: params[:title])
      end

      if params[:word].present?
        scope = scope.where("title LIKE :word OR question LIKE :word OR answer LIKE :word", word: "%#{params[:word]}%")
      end

      scope
    end
  end
end