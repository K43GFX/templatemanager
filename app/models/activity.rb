# Model to describe activity log's structure
class Activity
  include Mongoid::Document
  belongs_to :VM, optional: true

  field :action, type: String
  field :initiated_by, type: String
  field :date, type: Date

end
