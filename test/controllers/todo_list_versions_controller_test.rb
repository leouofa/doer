# frozen_string_literal: true

require "test_helper"

class TodoListVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @todo_list = TodoList.create!(title: "Architecture v1", body: "# Heading\n- [ ] Initial line")
    @v1 = @todo_list.latest_version
    @todo_list.update!(title: "Architecture v2", body: "# Heading\n- [x] Initial line\n- [ ] Extra line")
    @v2 = @todo_list.latest_version
  end

  test "should get versions index and show latest version diff by default" do
    get todo_list_versions_url(@todo_list)
    assert_response :success
    assert_select "h1", text: /Version History/
    assert_select "#version_timeline a", count: 2
    assert_select "#version_diff_container", text: /Extra line/
    assert_select "#title_diff_banner", text: /Architecture v1/
  end

  test "should get specific version in diff, rendered, and raw modes" do
    get todo_list_version_url(@todo_list, @v1, view: "rendered")
    assert_response :success
    assert_select "#version_rendered_container h1", text: "Heading"

    get todo_list_version_url(@todo_list, @v1, view: "raw")
    assert_response :success
    assert_select "#version_raw_container pre", text: /Initial line/
  end

  test "should restore previous version and create a new version" do
    assert_difference("@todo_list.versions.count", 1) do
      post restore_todo_list_version_url(@todo_list, @v1)
    end

    assert_redirected_to todo_list_url(@todo_list)
    @todo_list.reload
    assert_equal 3, @todo_list.current_version_number
    assert_equal "Architecture v1", @todo_list.title
    assert_equal "# Heading\n- [ ] Initial line", @todo_list.body
  end

  test "background auto_save updates todo list without creating a version while explicit update creates a version" do
    assert_no_difference("@todo_list.versions.count") do
      patch todo_list_url(@todo_list, format: :json), params: {
        auto_save: "1",
        todo_list: { body: "Auto-saved body change" }
      }
    end
    assert_response :ok
    assert_equal "Auto-saved body change", @todo_list.reload.body

    # Explicit save (auto_save: "0") commits the auto-saved draft as a new version
    assert_difference("@todo_list.versions.count", 1) do
      patch todo_list_url(@todo_list, format: :json), params: {
        auto_save: "0",
        todo_list: { body: "Auto-saved body change" }
      }
    end
    assert_response :ok
    assert_equal 3, @todo_list.reload.current_version_number
  end
end
