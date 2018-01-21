class Clone
  include Mongoid::Document

  field :dollythesheep, type: String
  field :nickname, type: String
  field :newsnapshot, type: Boolean

end
