class Micropost < ApplicationRecord
  # マイクロポストがユーザーに所属する関連付け
  belongs_to :user
  default_scope -> {order(created_at: :desc)}   # created_atカラムの降順に順序付け(最新のマイクロポストを最初に表示させるため)
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: 140}
end
