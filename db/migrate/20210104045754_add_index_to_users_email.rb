class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    # usersテーブルのemailカラムにインデックス(本で言う索引。検索効率上がる)を追加
    # インデックス自体は一意性を持たないが、unique: trueで持たせている
    add_index :users, :email, unique: true
  end
end
