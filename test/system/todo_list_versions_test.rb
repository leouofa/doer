# frozen_string_literal: true

require "application_system_test_case"

class TodoListVersionsTest < ApplicationSystemTestCase
  setup do
    @todo_list = TodoList.create!(title: "Versioned TodoList v1", body: "- [ ] First version task")
    @todo_list.update!(title: "Versioned TodoList v2", body: "- [x] Second version task")
  end

  test "viewing version history, inspecting diffs, and restoring a previous version" do
    visit todo_list_url(@todo_list)
    assert_text "History (v2)"

    click_on "History (v2)"
    assert_selector "h1", text: "Version History"
    assert_text "2 versions"
    assert_text "+1"
    assert_text "-1"
    assert_text "Second version task"

    # Click on v1 in timeline
    find("#version_item_1").click
    assert_text "First version task"
    assert_button "Restore v1"

    accept_confirm do
      click_on "Restore v1"
    end

    assert_text "Restored todo list to v1 (saved as v3)."
    assert_selector "h1", text: "Versioned TodoList v1"
    assert_text "History (v3)"
    assert_text "First version task"
  end
end
