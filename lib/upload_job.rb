class UploadJob < Struct.new(:row,:project_id)
  # Method will be invoked when a new uoload job is added. This method
  # will update the issues at gitlab and will create the records
  # in the localdb
  #
  # Returns None.
  def perform
   tc_id = row[0]
   status = row[9]
   title = row[1]
   component = row[4]
   priority = row[2]
   severity = row[3]
   new_issue = $Gitlab_client.create_issue(project_id,row[1],{:description=>prepare_issue_body(row),:labels=>["import",status,component,priority,severity]})
   project = Project.find_by_gitlab_id(project_id)
    # After the update at gitlab, now update the same at the local db.
    project.issues.create(:gitlab_id=>new_issue.id,:title=>title,:tc_id=>tc_id,:status=>status)
  end
  # Method will prepare the body of the issue with the steps, expected
  # result and the actual result.
  #
  # issue = A single gitlab issue row from the csv file.
  #
  # Examples
  #   prepare_issue_body(row[1])
  #
  # Returns the updated body with the gitlab markup.
  def prepare_issue_body issue
    @steps = issue[6]
    @expected = issue[7]
    @actual = issue[8]
    body = "\n## Steps to Reproduce
    \n#{@steps}
    \n## Expected Result
    \n#{@expected}
    \n## Actual Result
    \n#{@actual}"
  end
end