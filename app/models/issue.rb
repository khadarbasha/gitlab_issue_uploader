class Issue < ActiveRecord::Base

  # Assosiate the Issue model with Project model.
  belongs_to :project

  # Attribute accessors.
  attr_accessible :gitlab_id, :status, :tc_id, :title

  # Validations.
  validates :gitlab_id, uniqueness: true, presence: true
  validates :tc_id, uniqueness: true, presence: true
  validates :status, presence: true
  validates :title, presence: true

  # Model method will convert the issue data to the csv format.
  #
  # issues = Array of all the issues matching the user requirement.
  #
  # all_projects_selcted = A boolean to print the project name in the csv.
  #
  # Examples
  #   Issue.to_csv(issues,true)
  #
  # Returns the csv file with the issue data.
  def self.to_csv(issues,all_projects_selected)
    column_names = {"TC ID"=>"tc_id","GitLab ID"=>"gitlab_id","Title"=>"title","Status"=>"status"}
    column_names["Project Name"]="" if all_projects_selected == true
    column_ids = column_names.values
    CSV.generate do |csv|
      csv << column_names.keys
      issues.each do |issue|
        data_items = issue.attributes.values_at(*column_ids)
        if all_projects_selected == true
          data_items.pop
          data_items.push(Project.find(issue.project_id).name)
        end
        csv << data_items
      end
    end
  end
end
