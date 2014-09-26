class ApiKey < ActiveRecord::Base
  belongs_to :user
  belongs_to :created_by, class_name: User

  validates_presence_of :key
  validates_uniqueness_of :user_id

  def regenerate!(updated_by)
    self.key = SecureRandom.hex(32)
    self.created_by = updated_by
    save!
  end

  def self.create_master_key
    api_key = ApiKey.find_by(user_id: nil)
    if api_key.blank?
      api_key = ApiKey.create(key: SecureRandom.hex(32), created_by: Mike.system_user)
    end
    api_key
  end

end