module ProjectsHelper
  # Helper method will get the project list from the gitlab api.
  #
  # Examples
  #   load_from_gitlab
  #
  # Returns the project list.
  def load_from_gitlab
    @projects = $Gitlab_client.projects
    projects_local_db = Project.pluck(:gitlab_id)
    @projects.each do |project|
      projects_local_db = projects_local_db - [project.id]
      if Project.find_by_gitlab_id(project.id) == nil
        Project.create(:gitlab_id=>project.id, :name=>project.name)
      end
    end
    projects_local_db.each do |id|
      project = Project.find_by_gitlab_id(id)
      project.destroy
    end
  end
end
