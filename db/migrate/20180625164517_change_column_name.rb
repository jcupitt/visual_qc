class ChangeColumnName < ActiveRecord::Migration[5.1]
  def change
    rename_column :votes, :vote, :vote_value
  end
end
