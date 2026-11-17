# frozen_string_literal: true

class TodoListVersion < ApplicationRecord
  belongs_to :todo_list, inverse_of: :versions

  validates :version_number,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: { scope: :todo_list_id }
  validates :title, presence: true

  scope :ordered, -> { order(version_number: :desc) }
end
