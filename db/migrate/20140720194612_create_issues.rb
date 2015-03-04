class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.integer :gitlab_id
      t.string :tc_id
      t.string :status
      t.references :project

      t.timestamps
    end
    add_index :issues, :project_id
  end
end
