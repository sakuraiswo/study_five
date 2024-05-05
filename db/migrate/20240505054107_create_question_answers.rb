class CreateQuestionAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :question_answers do |t|
      t.text :question
      t.text :answer
      t.integer :study_count
      t.references :room, null: false, foreign_key: true
      t.timestamps
    end
  end
end
