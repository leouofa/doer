require "test_helper"

class TodoListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = Project.create!(name: "Alpha Project")
    @standalone_todo_list = TodoList.create!(title: "TodoList A", body: "# Standalone Body\n\n- [ ] Task 1")
    @project_todo_list = TodoList.create!(project: @project, title: "TodoList AA", body: "# Assigned Body\n\n- [x] Done task")
  end

  test "should get index with standalone scope by default" do
    get todo_lists_url
    assert_response :success
    assert_select "h1", text: /Standalone Lists/
    assert_select "a", text: @standalone_todo_list.title
  end

  test "should get index with all scope" do
    get todo_lists_url(scope: "all")
    assert_response :success
    assert_select "h1", text: /All Todo Lists/
    assert_select "a", text: @standalone_todo_list.title
    assert_select "a", text: @project_todo_list.title
  end

  test "should search todo lists" do
    get todo_lists_url(q: "Assigned")
    assert_response :success
    assert_select "a", text: @project_todo_list.title
  end

  test "should get show with rendered markdown" do
    get todo_list_url(@standalone_todo_list)
    assert_response :success
    assert_select "h1", text: @standalone_todo_list.title
    assert_select "#rendered_markdown_container h1", text: "Standalone Body"
    assert_select "#rendered_markdown_container input[type='checkbox']"
  end

  test "should get new" do
    get new_todo_list_url
    assert_response :success
  end

  test "should create standalone todo list" do
    assert_difference("TodoList.count") do
      post todo_lists_url, params: { todo_list: { title: "New List", body: "- [ ] Item" } }
    end

    new_list = TodoList.last
    assert_nil new_list.project_id
    assert_redirected_to todo_list_url(new_list)
  end

  test "should create todo list assigned to project" do
    assert_difference("TodoList.count") do
      post todo_lists_url, params: { todo_list: { title: "Assigned List", body: "- [ ] Body", project_id: @project.id } }
    end

    new_list = TodoList.last
    assert_equal @project.id, new_list.project_id
    assert_redirected_to todo_list_url(new_list)
  end

  test "should update todo list via HTML" do
    patch todo_list_url(@standalone_todo_list), params: { todo_list: { title: "Renamed Title", body: "- [x] Done" } }
    assert_redirected_to todo_list_url(@standalone_todo_list)
    assert_equal "Renamed Title", @standalone_todo_list.reload.title
  end

  test "should update todo list via JSON for auto-save" do
    patch todo_list_url(@standalone_todo_list, format: :json), params: { todo_list: { body: "Auto-saved content" } }
    assert_response :ok
    assert_equal "Auto-saved content", @standalone_todo_list.reload.body
  end

  test "should attach files via ActiveStorage endpoint" do
    FileUtils.mkdir_p(Rails.root.join("test/fixtures/files"))
    File.write(Rails.root.join("test/fixtures/files/sample.txt"), "Sample todo list attachment content")
    file = fixture_file_upload("sample.txt", "text/plain")

    assert_difference("@standalone_todo_list.files.count", 1) do
      post attach_files_todo_list_url(@standalone_todo_list), params: { files: [ file ] }
    end

    assert_redirected_to todo_list_url(@standalone_todo_list)
    assert_equal "sample.txt", @standalone_todo_list.files.last.filename.to_s
  end

  test "should purge attachment" do
    FileUtils.mkdir_p(Rails.root.join("test/fixtures/files"))
    File.write(Rails.root.join("test/fixtures/files/sample.txt"), "Sample attachment")
    file = fixture_file_upload("sample.txt", "text/plain")
    @standalone_todo_list.files.attach(file)
    attachment = @standalone_todo_list.files.last

    assert_difference("@standalone_todo_list.files.count", -1) do
      delete attachment_todo_list_url(@standalone_todo_list, attachment.id)
    end

    assert_redirected_to todo_list_url(@standalone_todo_list)
  end

  test "should destroy todo list" do
    assert_difference("TodoList.count", -1) do
      delete todo_list_url(@standalone_todo_list)
    end

    assert_redirected_to root_url
  end

  test "should toggle pin for todo list" do
    assert_not @standalone_todo_list.pinned?
    patch toggle_pin_todo_list_url(@standalone_todo_list)
    assert_redirected_to todo_list_url(@standalone_todo_list)
    assert @standalone_todo_list.reload.pinned?

    patch toggle_pin_todo_list_url(@standalone_todo_list, format: :json)
    assert_response :ok
    assert_not @standalone_todo_list.reload.pinned?
  end

  test "should reorder pinned todo lists" do
    t1 = TodoList.create!(title: "T1", pinned: true, pinned_position: 1)
    t2 = TodoList.create!(title: "T2", pinned: true, pinned_position: 2)

    patch reorder_pinned_todo_lists_url(format: :json), params: { todo_list_ids: [ t2.id, t1.id ] }
    assert_response :ok

    assert_equal 1, t2.reload.pinned_position
    assert_equal 2, t1.reload.pinned_position
  end

  test "sidebar displays project names and counts" do
    get todo_lists_url
    assert_response :success
    assert_select "span", text: "Projects"
    assert_select "span", text: @project.name
  end

  test "sidebar displays clickable Standalone Lists and Pinned Lists" do
    @standalone_todo_list.toggle_pin!
    get todo_lists_url
    assert_response :success

    assert_select "nav a[href=?]", todo_lists_path(scope: "standalone"), text: /Standalone Lists/
    assert_select "span", text: "Pinned Lists"
    assert_select "[data-controller='pinned-sortable'] a", text: @standalone_todo_list.title
  end
end
