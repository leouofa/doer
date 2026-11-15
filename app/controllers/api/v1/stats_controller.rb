module Api
  module V1
    class StatsController < BaseController
      def show
        render json: {
          total_todo_lists: TodoList.count,
          standalone_todo_lists: TodoList.standalone.count,
          pinned_todo_lists: TodoList.where(pinned: true).count,
          total_projects: Project.count,
          total_attachments: ActiveStorage::Attachment.where(record_type: "TodoList").count
        }
      end
    end
  end
end
