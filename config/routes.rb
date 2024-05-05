Rails.application.routes.draw do
  root to: 'rooms#index'
  resources :rooms do
    resources :question_answers
  end
end
