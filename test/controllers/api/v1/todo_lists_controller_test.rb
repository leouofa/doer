require "test_helper"

class Api::V1::TodoListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = Project.create!(name: "API Studio")
    @standalone_todo_list = TodoList.create!(title: "Standalone Todo List", body: "# Markdown Header\nSome *content*")
    @assigned_todo_list = TodoList.create!(project: @project, title: "Assigned Todo List", body: "Assigned list body")
    @pinned_todo_list = TodoList.create!(title: "Pinned Todo List", body: "Important content", pinned: true, pinned_position: 1)
  end

  test "GET /api/v1/todo_lists lists all todo lists" do
    get api_v1_todo_lists_url, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert json.key?("todo_lists")
    assert json.key?("meta")
    assert_equal 3, json["meta"]["total_count"]
    titles = json["todo_lists"].map { |t| t["title"] }
    assert_includes titles, @standalone_todo_list.title
    assert_includes titles, @assigned_todo_list.title
    assert_includes titles, @pinned_todo_list.title
  end

  test "GET /api/v1/todo_lists filters by project_id" do
    get api_v1_todo_lists_url, params: { project_id: @project.id }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["todo_lists"].size
    assert_equal @assigned_todo_list.title, json["todo_lists"].first["title"]
  end

  test "GET /api/v1/todo_lists filters by standalone scope" do
    get api_v1_todo_lists_url, params: { scope: "standalone" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    titles = json["todo_lists"].map { |t| t["title"] }
    assert_includes titles, @standalone_todo_list.title
    assert_includes titles, @pinned_todo_list.title
    refute_includes titles, @assigned_todo_list.title
  end

  test "GET /api/v1/todo_lists filters by pinned state" do
    get api_v1_todo_lists_url, params: { pinned: "true" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["todo_lists"].size
    assert_equal @pinned_todo_list.title, json["todo_lists"].first["title"]
  end

  test "GET /api/v1/todo_lists searches by keyword" do
    get api_v1_todo_lists_url, params: { q: "Markdown" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal 1, json["todo_lists"].size
    assert_equal @standalone_todo_list.title, json["todo_lists"].first["title"]
  end

  test "GET /api/v1/todo_lists/:id returns todo list details and attachments" do
    get api_v1_todo_list_url(@standalone_todo_list), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal @standalone_todo_list.id, json["id"]
    assert_equal "Standalone Todo List", json["title"]
    assert_equal @standalone_todo_list.body, json["body"]
    assert json.key?("attachments")
    assert_equal 0, json["attachments"].size
  end

  test "GET /api/v1/todo_lists/:id with render_markdown=true includes rendered_html" do
    get api_v1_todo_list_url(@standalone_todo_list), params: { render_markdown: "true" }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert json.key?("rendered_html")
    assert_includes json["rendered_html"], "<h1>Markdown Header</h1>"
    assert_includes json["rendered_html"], "<em>content</em>"
  end

  test "POST /api/v1/todo_lists creates a todo list" do
    assert_difference("TodoList.count", 1) do
      post api_v1_todo_lists_url, params: {
        todo_list: {
          title: "New API Todo List",
          body: "- [ ] Task 1",
          project_id: @project.id,
          pinned: false
        }
      }, as: :json
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "New API Todo List", json["title"]
    assert_equal "- [ ] Task 1", json["body"]
    assert_equal @project.id, json["project_id"]
    assert_equal "API Studio", json["project_name"]
  end

  test "POST /api/v1/todo_lists with invalid params returns 422" do
    assert_no_difference("TodoList.count") do
      post api_v1_todo_lists_url, params: { todo_list: { title: "" } }, as: :json
    end

    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "Validation failed", json["error"]
    assert_includes json["details"], "Title can't be blank"
  end

  test "PATCH /api/v1/todo_lists/:id updates todo list" do
    patch api_v1_todo_list_url(@standalone_todo_list), params: {
      todo_list: {
        title: "Updated Title",
        body: "Updated Body"
      }
    }, as: :json

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "Updated Title", json["title"]
    assert_equal "Updated Body", json["body"]
    assert_equal "Updated Title", @standalone_todo_list.reload.title
  end

  test "DELETE /api/v1/todo_lists/:id deletes todo list" do
    assert_difference("TodoList.count", -1) do
      delete api_v1_todo_list_url(@standalone_todo_list), as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
  end

  test "PATCH /api/v1/todo_lists/:id/toggle_pin toggles pin state" do
    patch toggle_pin_api_v1_todo_list_url(@standalone_todo_list), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal true, json["pinned"]
    assert_not_nil json["pinned_position"]
    assert @standalone_todo_list.reload.pinned?

    patch toggle_pin_api_v1_todo_list_url(@standalone_todo_list), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal false, json["pinned"]
    assert_nil json["pinned_position"]
    refute @standalone_todo_list.reload.pinned?
  end

  test "PATCH /api/v1/todo_lists/reorder_pinned reorders pinned todo lists" do
    list2 = TodoList.create!(title: "Second Pinned", pinned: true, pinned_position: 2)

    patch reorder_pinned_api_v1_todo_lists_url, params: { todo_list_ids: [ list2.id, @pinned_todo_list.id ] }, as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
    assert_equal 1, list2.reload.pinned_position
    assert_equal 2, @pinned_todo_list.reload.pinned_position
  end
end
