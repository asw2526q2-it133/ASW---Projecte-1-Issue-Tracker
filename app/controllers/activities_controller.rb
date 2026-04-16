class ActivitiesController < ApplicationController
  def index
    @activities = Activity.includes(:user, :issue).order(created_at: :desc)
  end
end
