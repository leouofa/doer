require "test_helper"

class Api::V1::TodoListAttachmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @todo_list = TodoList.create!(title: "Attachment Todo List", body: "- [ ] Sample body")
    FileUtils.mkdir_p(Rails.root.join("test/fixtures/files"))
    File.write(Rails.root.join("test/fixtures/files/sample.txt"), "Sample attachment content")
  end

  test "GET /api/v1/todo_lists/:id/attachments lists attachments" do
    file = fixture_file_upload("sample.txt", "text/plain")
    @todo_list.files.attach(file)

    get attachments_api_v1_todo_list_url(@todo_list), as: :json
    assert_response :success

    json = JSON.parse(response.body)
    assert json.key?("attachments")
    assert_equal 1, json["attachments"].size

    att = json["attachments"].first
    assert_equal "sample.txt", att["filename"]
    assert_equal "text/plain", att["content_type"]
    assert_not_nil att["url"]
  end

  test "POST /api/v1/todo_lists/:id/attachments attaches uploaded files" do
    file = fixture_file_upload("sample.txt", "text/plain")

    assert_difference("@todo_list.files.count", 1) do
      post attachments_api_v1_todo_list_url(@todo_list), params: { files: [ file ] }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
    assert_equal 1, json["attachments"].size
    assert_equal "sample.txt", json["attachments"].first["filename"]
  end

  test "POST /api/v1/todo_lists/:id/attachments with no files returns 400" do
    post attachments_api_v1_todo_list_url(@todo_list), params: {}, as: :json
    assert_response :bad_request

    json = JSON.parse(response.body)
    assert_equal "No files provided for attachment", json["error"]
  end

  test "DELETE /api/v1/todo_lists/:id/attachments/:attachment_id purges attachment" do
    file = fixture_file_upload("sample.txt", "text/plain")
    @todo_list.files.attach(file)
    attachment = @todo_list.files.last

    assert_difference("@todo_list.files.count", -1) do
      delete attachments_api_v1_todo_list_url(@todo_list) + "/#{attachment.id}", as: :json
    end

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "ok", json["status"]
    assert_equal "Attachment removed successfully", json["message"]
  end
end
