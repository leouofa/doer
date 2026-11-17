# frozen_string_literal: true

class CreateTodoListVersions < ActiveRecord::Migration[8.1]
  def up
    create_table :todo_list_versions do |t|
      t.references :todo_list, null: false, foreign_key: { on_delete: :cascade }
      t.integer :version_number, null: false
      t.string :title, null: false
      t.text :body, default: "", null: false
      t.datetime :created_at, null: false
    end

    add_index :todo_list_versions, %i[todo_list_id version_number], unique: true
    add_index :todo_list_versions, %i[todo_list_id created_at]

    execute <<~SQL.squish
      INSERT INTO todo_list_versions (todo_list_id, version_number, title, body, created_at)
      SELECT id, 1, title, body, created_at
      FROM todo_lists
    SQL
  end

  def down
    drop_table :todo_list_versions
  end
end
