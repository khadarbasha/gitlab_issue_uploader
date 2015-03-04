class Project < ActiveRecord::Base

  # Attribute accessors.
  attr_accessible :gitlab_id, :name

  # Assosiate the Project model with Issue model.
  has_many :issues, :dependent => :destroy

  # Validations
  validates :gitlab_id, uniqueness: true, presence: true
  validates :name, presence: true

end
