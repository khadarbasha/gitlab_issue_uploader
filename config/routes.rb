GitlabIssuesUploader::Application.routes.draw do
  root :to => "projects#index"
  match 'projects/update' => 'projects#update'

  match 'issues' => 'issues#index', :as=> :issues
  match ':id/browse_issues' => 'issues#browse', :as=> :browse_issues_id
  match 'browse' => 'issues#browse', :as=> :browse_issues
  match 'import' => 'issues#import', :as=> :import_issues
  match 'export' => 'issues#export', :as=> :export_issues
  match 'download' => 'issues#download', :as=> :download_issues

end
