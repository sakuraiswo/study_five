class AddUserRefToRooms < ActiveRecord::Migration[7.0]
  def change
    # add_reference :rooms, :user, null: true, foreign_key: true
  end
end
