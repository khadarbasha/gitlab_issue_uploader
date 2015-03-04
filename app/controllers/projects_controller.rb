class ProjectsController < ApplicationController
  include ProjectsHelper
  # Controller method will invoke the corresponding view page(index.html.erb).
  #
  #
  # Examples
  #   index
  #
  # Redirect the user to the index.html.erb page with the project list.
  def index
    # Update the project list from the gitlab, if there exists no projects in the list.
    load_from_gitlab if Project.count == 0
    @projects = Project.all
  end
  # Controller method will update the records from the gitlab and
  # will redirect the user to the root page.
  #
  #
  # Examples
  #   update
  #
  # Redirect the user to the root page.
  def update
    load_from_gitlab
    flash["notice"] = "Project List updated successfully."
    redirect_to root_path
  end
end