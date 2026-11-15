class CreateTodoLists < ActiveRecord::Migration[8.1]
  def change
    create_table :todo_lists do |t|
      t.references :project, null: true, foreign_key: { on_delete: :nullify }
      t.string :title, null: false
      t.text :body, default: "", null: false
      t.boolean :pinned, default: false, null: false
      t.integer :pinned_position

      t.timestamps
    end

    add_index :todo_lists, [ :pinned, :pinned_position ]
    add_index :todo_lists, :updated_at
  end
end
