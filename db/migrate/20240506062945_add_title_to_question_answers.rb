class AddTitleToQuestionAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :question_answers, :title, :string
  end
end
