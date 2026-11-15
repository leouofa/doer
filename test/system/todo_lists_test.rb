require "application_system_test_case"

class TodoListsTest < ApplicationSystemTestCase
  setup do
    @todo_list = TodoList.create!(title: "System Test List", body: "# Hello World\n\n- [ ] Task 1\n- [x] Task 2")
  end

  test "visiting the index and viewing todo list" do
    visit root_url
    assert_selector "h1", text: "Standalone Lists"
    assert_text "System Test List"

    within "main" do
      click_on "System Test List"
    end
    assert_selector "h1", text: "System Test List"
    assert_text "Hello World"
  end

  test "creating a new todo list" do
    visit root_url
    within "main" do
      click_on "New Todo List"
    end

    fill_in "Todo List Title", with: "Created via System Test"
    fill_in "Markdown Content", with: "- [ ] System test task"
    click_on "Create Todo List"

    assert_text "Todo list created successfully."
    assert_text "Created via System Test"
  end

  test "clicking todo list card navigates to list details" do
    visit root_url
    find(".group.relative", text: "System Test List").click
    assert_selector "h1", text: "System Test List"
  end

  test "pinning and unpinning a todo list from card" do
    visit root_url
    assert_text "No pinned lists yet."

    within "main" do
      click_on "Pin"
    end

    assert_text "Pinned"
    within "aside" do
      assert_text "System Test List"
    end

    within "main" do
      click_on "Pinned"
    end

    within "aside" do
      assert_text "No pinned lists yet."
    end
  end

  test "pin, copy, and toolbar buttons have pointer cursor" do
    visit root_url
    assert_equal "pointer", find("button", text: "Pin").native.css_value("cursor")
    assert_equal "pointer", find("button", text: "Copy").native.css_value("cursor")

    within "main" do
      click_on "System Test List"
    end
    assert_selector "h1", text: "System Test List"

    assert_equal "pointer", find("button", text: "Pin").native.css_value("cursor")
    assert_equal "pointer", find("button", text: "Copy Markdown").native.css_value("cursor")
    assert_equal "pointer", find("[data-markdown-editor-target='previewTab']").native.css_value("cursor")
    assert_equal "pointer", find("[data-markdown-editor-target='editTab']").native.css_value("cursor")
    assert_equal "pointer", find("[data-markdown-editor-target='splitTab']").native.css_value("cursor")
  end
end
