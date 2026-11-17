# frozen_string_literal: true

class TodoListVersionsController < ApplicationController
  before_action :set_todo_list
  before_action :load_versions, only: %i[index show]

  def index
    @selected_version = if params[:version_id].present?
      @versions.find(params[:version_id])
    else
      @versions.first
    end

    prepare_comparison
  end

  def show
    @selected_version = @versions.find(params[:id])
    prepare_comparison
    render :index
  end

  def restore
    @version = @todo_list.versions.find(params[:id])
    @todo_list.restore_version!(@version)

    redirect_to todo_list_path(@todo_list),
                notice: "Restored todo list to v#{@version.version_number} (saved as v#{@todo_list.current_version_number})."
  end

  private

  def set_todo_list
    @todo_list = TodoList.find(params[:todo_list_id])
  end

  def load_versions
    @todo_list.record_version_snapshot! if @todo_list.versions.empty?
    @versions = @todo_list.versions.ordered
  end

  def prepare_comparison
    return unless @selected_version

    @view_mode = params[:view].presence_in(%w[diff rendered raw]) || "diff"

    @previous_version = if params[:compare_id].present?
      @versions.find_by(id: params[:compare_id])
    else
      @todo_list.versions
                .where("version_number < ?", @selected_version.version_number)
                .order(version_number: :desc)
                .first
    end

    @diff = TodoListDiffer.call(
      @previous_version&.body.to_s,
      @selected_version.body,
      old_title: @previous_version&.title,
      new_title: @selected_version.title
    )
  end
end
