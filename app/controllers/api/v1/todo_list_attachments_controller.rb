module Api
  module V1
    class TodoListAttachmentsController < BaseController
      before_action :set_todo_list

      def index
        render json: {
          attachments: @todo_list.files.map { |file| attachment_json(file) }
        }
      end

      def create
        if params[:files].blank?
          return render_error("No files provided for attachment", status: :bad_request)
        end

        @todo_list.files.attach(params[:files])

        render json: {
          status: "ok",
          attachments: @todo_list.files.map { |file| attachment_json(file) }
        }, status: :created
      end

      def destroy
        attachment = @todo_list.files.find(params[:attachment_id])
        attachment.purge

        render json: {
          status: "ok",
          message: "Attachment removed successfully"
        }
      end

      private

      def set_todo_list
        @todo_list = TodoList.find(params[:id])
      end
    end
  end
end
