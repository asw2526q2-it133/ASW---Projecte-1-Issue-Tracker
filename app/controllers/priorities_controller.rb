class PrioritiesController < ApplicationController
  # before_action :authenticate_user!
  before_action :set_priority, only: %i[ show edit update destroy ]

  def index
    @priorities = Priority.all
  end

  def show
  end

  def new
    @priority = Priority.new
  end

  def edit
  end

  def create
    @priority = Priority.new(priority_params)

    respond_to do |format|
      if @priority.save
        format.html { redirect_to priorities_url, notice: "La prioridad se creó correctamente." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @priority.update(priority_params)
        format.html { redirect_to priorities_url, notice: "La prioridad se actualizó correctamente.", status: :see_other }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    # Quitamos la exclamación para que el modelo pueda bloquear el borrado amigablemente
    if @priority.destroy
      respond_to do |format|
        format.html { redirect_to priorities_url, notice: "La prioridad fue eliminada.", status: :see_other }
      end
    else
      respond_to do |format|
        format.html { redirect_to priorities_url, alert: @priority.errors.full_messages.to_sentence, status: :see_other }
      end
    end
  end

  private
    def set_priority
      @priority = Priority.find(params.expect(:id))
    end

    def priority_params
      params.expect(priority: [ :name, :color ])
    end
end
