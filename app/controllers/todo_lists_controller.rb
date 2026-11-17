class TodoListsController < ApplicationController
  before_action :set_todo_list, only: %i[show edit update destroy toggle_pin attach_files purge_attachment]

  def index
    @scope = params[:scope].presence

    base_scope = if params[:q].present?
      @scope == "standalone" ? TodoList.standalone : TodoList.all
    elsif @scope == "all"
      TodoList.all
    else
      @scope = "standalone"
      TodoList.standalone
    end

    @todo_lists = base_scope.recent
    if params[:q].present?
      @todo_lists = @todo_lists.search(params[:q])
    end
  end

  def show
  end

  def new
    @todo_list = TodoList.new(project_id: params[:project_id])
  end

  def edit
  end

  def create
    @todo_list = TodoList.new(todo_list_params)

    if @todo_list.save
      redirect_to @todo_list, notice: "Todo list created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    auto_save = params[:auto_save].to_s == "1" || params[:auto_save].to_s == "true"
    @todo_list.skip_versioning = auto_save

    if @todo_list.update(todo_list_params)
      @todo_list.record_version_snapshot! unless auto_save

      respond_to do |format|
        format.html { redirect_to @todo_list, notice: "Todo list updated successfully." }
        format.json { render json: { status: :ok, todo_list: @todo_list } }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: { errors: @todo_list.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    redirect_target = @todo_list.project ? project_path(@todo_list.project) : root_path
    @todo_list.destroy
    redirect_to redirect_target, notice: "Todo list deleted successfully."
  end

  def toggle_pin
    @todo_list.toggle_pin!

    respond_to do |format|
      format.html { redirect_back_or_to @todo_list }
      format.json { render json: { status: :ok, pinned: @todo_list.pinned?, pinned_position: @todo_list.pinned_position } }
    end
  end

  def reorder_pinned
    todo_list_ids = params[:todo_list_ids] || []

    TodoList.transaction do
      todo_list_ids.each_with_index do |id, index|
        TodoList.where(id: id, pinned: true).update_all(pinned_position: index + 1)
      end
    end

    respond_to do |format|
      format.json { render json: { status: :ok } }
      format.html { redirect_back_or_to root_path }
    end
  end

  def attach_files
    if params[:files].present?
      @todo_list.files.attach(params[:files])
    end

    respond_to do |format|
      format.html { redirect_to @todo_list, notice: "Files attached successfully." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "todo_list_attachments",
          partial: "todo_lists/attachments",
          locals: { todo_list: @todo_list }
        )
      end
      format.json { render json: { status: :ok, count: @todo_list.files.count } }
    end
  end

  def purge_attachment
    attachment = @todo_list.files.find(params[:attachment_id])
    attachment.purge

    respond_to do |format|
      format.html { redirect_to @todo_list, notice: "Attachment removed." }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "todo_list_attachments",
          partial: "todo_lists/attachments",
          locals: { todo_list: @todo_list }
        )
      end
    end
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:id])
  end

  def todo_list_params
    params.require(:todo_list).permit(:title, :body, :project_id, files: [])
  end
end
