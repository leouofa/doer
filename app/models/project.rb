class Project < ApplicationRecord
  has_many :todo_lists, -> { order(updated_at: :desc) }, dependent: :nullify

  validates :name, presence: true
end
