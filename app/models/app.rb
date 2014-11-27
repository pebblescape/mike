# TODO: delete containers etc when deleting
class App < ActiveRecord::Base
  belongs_to :owner, class_name: User

  validates_presence_of :name
  validates_uniqueness_of :name
end
