class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :load_sidebar_data

  private

  def load_sidebar_data
    @sidebar_projects = Project.order(:name).includes(:todo_lists)
    @sidebar_pinned_todo_lists = TodoList.pinned
    @sidebar_total_standalone_count = TodoList.standalone.count
    @sidebar_total_todo_lists_count = TodoList.count
  end
end
