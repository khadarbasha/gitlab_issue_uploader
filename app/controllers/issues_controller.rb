class IssuesController < ApplicationController
  include IssuesHelper
  # Controller method will invoke the corresponding view page(index.html.erb)
  #
  #
  # Examples
  #   index
  #
  # Invoke the index.html.erb page.
  def index
  end
  # Controller method will get the response from the users project selection (
  # through index.html.erb page), and will redirect the user to the browse page
  # (browse.html.erb)
  #
  # params[:id] = Project id in case of project id passed in the url.
  # params[:user_pick] = Project id in case project id passed through the form.
  #
  # Examples
  #   browse
  #
  # Redirect the project id to the browse.html.erb page.
  def browse
    if params[:id]==nil && params[:user_pick] ==nil
      flash[:error] = "Pick any project to continue.."
      redirect_to root_path
      return
    end
    @project_id = params[:id]||params[:user_pick][:project]
  end
  # Controller method will get the csv file from the browse page, and will use
  # the same to create the issues in gitlab and in local database. After the
  # successfull creation of the records user will be redirected to the browse
  # page (browse.html.erb).
  #
  # params[:file_upload][:file] = CSV file with the Gitlab issues.
  #
  # Examples
  #   import
  #
  # Redirect the user to the browse page (browse.html.erb) with the appropriate
  # status messages.
  def import
    if params[:file_upload][:file] == nil
     flash[:error] = "You can't proceed with out file selection."
     redirect_to :controller => 'issues', :action => 'browse', :id => params[:file_upload][:project_id]
     return
    else
      csv_file = params[:file_upload][:file].tempfile
      csv_data = CSV.read(csv_file)
      project_id = params[:file_upload][:project_id]
      csv_data.shift
      csv_data.each do |row|
        tc_id = row[0]
        status = row[9]
        title = row[1]
        component = row[4]
        priority = row[2]
        severity = row[3]
        # Used to maintain the uniqueness of issues.
        if Issue.find_by_tc_id(row[0])!=nil
          flash[:error] = "Duplicated Entry for : #{row[0]}. Last updated issue is #{Issue.last.tc_id}, Upload aborted."
          redirect_to :controller => 'issues', :action => 'browse', :id => project_id
          return
        end
        Delayed::Job.enqueue(UploadJob.new(row,project_id))
        # Update the issue at gitlab only if the issue id (tc_id) is unique.
        #new_issue = $Gitlab_client.create_issue(project_id,row[1],{:description=>prepare_issue_body(row),:labels=>["import",status,component,priority,severity]})
        #project = Project.find_by_gitlab_id(project_id)
        # After the update at gitlab, now update the same at the local db.
        #project.issues.create(:gitlab_id=>new_issue.id,:title=>title,:tc_id=>tc_id,:status=>status)
      end
      flash[:notice] = "All the issues will be uploaded shortely."
      redirect_to :controller => 'issues', :action => 'browse', :id => project_id
    end
  end
  # Controller method will invoke the corresponding view page (export.html.
  # erb).
  #
  #
  # Examples
  #   export
  #
  # Redirect the user to the export.html.erb page.
  def export
  end
  # Controller method will get the response from the users project selection
  # (through export.html.erb page), and will export the issues to the csv file.
  #
  # params[:user_pick] = Project id captured from the export.html.erb page.
  #
  # Examples
  #   download
  #
  # Renders a csv file with the issues.
  def download
    user_query_passed = false
    all_projects = false
    user_query_passed = true if params[:user_pick] != nil
    all_projects = true if user_query_passed == true && params[:user_pick][:project]=="all"
    @issues = Issue.order(:created_at)
    @issues = Project.find_by_gitlab_id(params[:user_pick][:project]).issues.order(:created_at) if user_query_passed == true && all_projects == false
    render :text=>Issue.to_csv(@issues,all_projects)
  end
end