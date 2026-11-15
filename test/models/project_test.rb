require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "validates presence of name" do
    project = Project.new(name: "")
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"

    project.name = "My Project"
    assert project.valid?
  end

  test "has_many todo_lists with dependent nullify" do
    project = Project.create!(name: "Project A")
    todo_list = TodoList.create!(project: project, title: "Sprint Tasks", body: "- [ ] Task 1")

    assert_equal 1, project.todo_lists.count
    project.destroy
    assert_nil todo_list.reload.project_id
  end
end
