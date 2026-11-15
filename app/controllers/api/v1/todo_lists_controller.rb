module Api
  module V1
    class TodoListsController < BaseController
      before_action :set_todo_list, only: %i[show update destroy toggle_pin]

      def index
        scope = TodoList.all

        if params[:project_id].present?
          scope = scope.where(project_id: params[:project_id])
        elsif params[:scope] == "standalone"
          scope = scope.standalone
        end

        if params[:pinned].present?
          scope = params[:pinned].to_s == "true" ? scope.where(pinned: true) : scope.where(pinned: false)
        end

        if params[:q].present?
          scope = scope.search(params[:q])
        end

        # Preserve pinned ordering if specifically requested or default recent
        scope = if params[:pinned].to_s == "true"
          scope.pinned
        else
          scope.recent
        end

        paginated_todo_lists, meta = paginate_scope(scope)
        render json: {
          todo_lists: paginated_todo_lists.map { |tl| todo_list_json(tl, include_body: true) },
          meta: meta
        }
      end

      def show
        render_md = params[:render_markdown].to_s == "true" || params[:render_markdown].to_s == "1"
        render json: todo_list_json(@todo_list, include_body: true, render_markdown: render_md, include_attachments: true)
      end

      def create
        todo_list = TodoList.new(todo_list_params)

        if todo_list.save
          render json: todo_list_json(todo_list, include_body: true, include_attachments: true), status: :created
        else
          render_error("Validation failed", status: :unprocessable_entity, details: todo_list.errors.full_messages)
        end
      end

      def update
        if @todo_list.update(todo_list_params)
          render_md = params[:render_markdown].to_s == "true" || params[:render_markdown].to_s == "1"
          render json: todo_list_json(@todo_list, include_body: true, render_markdown: render_md, include_attachments: true)
        else
          render_error("Validation failed", status: :unprocessable_entity, details: @todo_list.errors.full_messages)
        end
      end

      def destroy
        @todo_list.destroy
        render json: { status: "ok", message: "Todo list deleted successfully" }
      end

      def toggle_pin
        @todo_list.toggle_pin!
        render json: {
          status: "ok",
          pinned: @todo_list.pinned?,
          pinned_position: @todo_list.pinned_position,
          todo_list: todo_list_json(@todo_list)
        }
      end

      def reorder_pinned
        todo_list_ids = params[:todo_list_ids] || []

        TodoList.transaction do
          todo_list_ids.each_with_index do |id, index|
            TodoList.where(id: id, pinned: true).update_all(pinned_position: index + 1)
          end
        end

        render json: { status: "ok", message: "Pinned todo lists reordered successfully" }
      end

      private

      def set_todo_list
        @todo_list = TodoList.find(params[:id])
      end

      def todo_list_params
        payload = params[:todo_list].is_a?(ActionController::Parameters) ? params[:todo_list] : params
        payload.permit(:title, :body, :project_id, :pinned, :pinned_position)
      end
    end
  end
end
