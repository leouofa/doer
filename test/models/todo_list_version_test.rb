# frozen_string_literal: true

require "test_helper"

class TodoListVersionTest < ActiveSupport::TestCase
  test "creating a todo list automatically creates initial v1 version" do
    todo_list = TodoList.create!(title: "Initial Title", body: "- [ ] Task 1")

    assert_equal 1, todo_list.versions.count
    assert_equal 1, todo_list.current_version_number

    v1 = todo_list.latest_version
    assert_equal 1, v1.version_number
    assert_equal "Initial Title", v1.title
    assert_equal "- [ ] Task 1", v1.body
    assert_not todo_list.unversioned_changes?
  end

  test "updating title or body creates sequential versions" do
    todo_list = TodoList.create!(title: "v1 Title", body: "- [ ] v1 task")

    todo_list.update!(body: "- [x] v1 task\n- [ ] v2 task")
    assert_equal 2, todo_list.versions.count
    assert_equal 2, todo_list.current_version_number
    assert_equal "- [x] v1 task\n- [ ] v2 task", todo_list.latest_version.body

    todo_list.update!(title: "v3 Title")
    assert_equal 3, todo_list.versions.count
    assert_equal 3, todo_list.current_version_number
    assert_equal "v3 Title", todo_list.latest_version.title

    assert_equal [ 3, 2, 1 ], todo_list.versions.ordered.pluck(:version_number)
  end

  test "updating non-content attributes like pinned or project_id does not create a version" do
    todo_list = TodoList.create!(title: "Pin Test", body: "Body content")
    assert_equal 1, todo_list.versions.count

    todo_list.toggle_pin!
    assert_equal 1, todo_list.versions.count

    project = Project.create!(name: "Test Project")
    todo_list.update!(project: project)
    assert_equal 1, todo_list.versions.count
  end

  test "skip_versioning prevents version creation on background auto-save until explicit snapshot" do
    todo_list = TodoList.create!(title: "Draft Todo List", body: "- [ ] Original")
    assert_equal 1, todo_list.versions.count

    todo_list.skip_versioning = true
    todo_list.update!(body: "- [ ] Auto-saved draft 1")
    assert_equal 1, todo_list.versions.count
    assert todo_list.unversioned_changes?

    todo_list.skip_versioning = true
    todo_list.update!(body: "- [ ] Auto-saved draft 2")
    assert_equal 1, todo_list.versions.count

    # Explicit save (even with no new column change on this call) snapshots the accumulated draft
    todo_list.skip_versioning = false
    todo_list.record_version_snapshot!
    assert_equal 2, todo_list.versions.count
    assert_equal "- [ ] Auto-saved draft 2", todo_list.latest_version.body
    assert_not todo_list.unversioned_changes?
  end

  test "restore_version! non-destructively restores a previous version as a new version" do
    todo_list = TodoList.create!(title: "Original Title", body: "- [ ] Task 1")
    v1 = todo_list.latest_version

    todo_list.update!(title: "Modified Title", body: "- [x] Task 1\n- [ ] Task 2")
    assert_equal 2, todo_list.current_version_number

    todo_list.restore_version!(v1)
    todo_list.reload

    assert_equal 3, todo_list.current_version_number
    assert_equal "Original Title", todo_list.title
    assert_equal "- [ ] Task 1", todo_list.body
    assert_equal "Original Title", todo_list.latest_version.title
    assert_equal "- [ ] Task 1", todo_list.latest_version.body
  end

  test "restore_version! preserves unversioned auto-saved changes before restoring" do
    todo_list = TodoList.create!(title: "v1", body: "- [ ] First")
    v1 = todo_list.latest_version

    todo_list.skip_versioning = true
    todo_list.update!(body: "- [ ] Unversioned auto-saved work")
    assert_equal 1, todo_list.versions.count

    todo_list.restore_version!(v1)
    todo_list.reload

    # v2 snapshots the unversioned draft, v3 is the restored v1
    assert_equal 3, todo_list.versions.count
    assert_equal "- [ ] Unversioned auto-saved work", todo_list.versions.find_by(version_number: 2).body
    assert_equal "- [ ] First", todo_list.versions.find_by(version_number: 3).body
  end

  test "destroying a todo list destroys its associated versions" do
    todo_list = TodoList.create!(title: "To be deleted", body: "Some content")
    assert_equal 1, TodoListVersion.where(todo_list_id: todo_list.id).count

    assert_difference "TodoListVersion.count", -1 do
      todo_list.destroy
    end
  end
end
