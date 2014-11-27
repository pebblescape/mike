require_dependency 'enum'

class Build < ActiveRecord::Base
  belongs_to :app
  belongs_to :user

  validates_presence_of :status
  
  def self.status_types
    @status_types ||= Enum.new(:pending, :failed, :succeeded)
  end
end
