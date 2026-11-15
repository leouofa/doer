require "test_helper"

class TodoListTest < ActiveSupport::TestCase
  test "validates presence of title" do
    todo_list = TodoList.new(title: "")
    assert_not todo_list.valid?
    assert_includes todo_list.errors[:title], "can't be blank"

    todo_list.title = "Valid Title"
    assert todo_list.valid?
  end

  test "can be standalone without a project" do
    todo_list = TodoList.create!(title: "Standalone List", body: "- [ ] Task 1")
    assert_nil todo_list.project
    assert_includes TodoList.standalone, todo_list
  end

  test "search scope filters by title and body" do
    t1 = TodoList.create!(title: "Rails Optimization", body: "Check N+1 queries")
    t2 = TodoList.create!(title: "Python Tips", body: "List comprehensions")

    assert_includes TodoList.search("Optimization"), t1
    assert_not_includes TodoList.search("Optimization"), t2

    assert_includes TodoList.search("queries"), t1
    assert_not_includes TodoList.search("queries"), t2
  end

  test "toggle_pin! toggles pinned state and manages pinned_position" do
    t1 = TodoList.create!(title: "List 1")
    t2 = TodoList.create!(title: "List 2")

    assert_not t1.pinned?
    t1.toggle_pin!
    assert t1.pinned?
    assert_equal 1, t1.pinned_position

    t2.toggle_pin!
    assert t2.pinned?
    assert_equal 2, t2.pinned_position

    assert_equal [ t1, t2 ], TodoList.pinned.to_a

    t1.toggle_pin!
    assert_not t1.pinned?
    assert_nil t1.pinned_position
    assert_equal [ t2 ], TodoList.pinned.to_a
  end
end
