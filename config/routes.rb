Rails.application.routes.draw do
  root to: 'rooms#index'
  resources :rooms do
    resources :question_answers do
      member do
        patch :increment_study_count
      end
    end
  end
end
