require_dependency 'pbkdf2'
require_dependency 'mike'

class User < ActiveRecord::Base
  default_scope { order(:created_at) }

  has_one :api_key, dependent: :destroy

  has_many :ssh_keys, dependent: :destroy
  has_many :apps,     dependent: :destroy, foreign_key: :owner_id
  has_many :builds
  has_many :releases
  has_many :dynos

  before_validation :downcase_email

  validates_presence_of :name
  validates :email, presence: true, uniqueness: true
  validate :password_validator

  before_save :ensure_password_is_hashed

  EMAIL = %r{([^@]+)@([^\.]+)}

  def self.new_from_params(params)
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user
  end

  def self.max_password_length
    200
  end

  # Find a user by temporary key, nil if not found or key is invalid
  def self.find_by_temporary_key(key)
    user_id = $redis.get("temporary_key:#{key}")
    if user_id.present?
      find_by(id: user_id)
    end
  end

  def self.find_by_email(email)
    find_by(email: email.strip.downcase)
  end

  # Use a temporary key to find this user, store it in redis with an expiry
  def temporary_key
    key = SecureRandom.hex(32)
    $redis.setex "temporary_key:#{key}", 2.months, id.to_s
    key
  end

  def self.email_hash(email)
    Digest::MD5.hexdigest(email.strip.downcase)
  end

  def email_hash
    User.email_hash(email)
  end

  def downcase_email
    self.email = self.email.downcase if self.email
  end

  def password_validator
    PasswordValidator.new(attributes: :password).validate_each(self, :password, @raw_password)
  end

  def confirm_password?(password)
    if ApiKey.where(key: password).first.try(:user) == self
      return true
    end

    return false unless password_hash && salt
    self.password_hash == hash_password(password, salt)
  end

  def self.gravatar_template(email)
    email_hash = self.email_hash(email)
    "//www.gravatar.com/avatar/#{email_hash}.png?s={size}&r=pg&d=identicon"
  end

  # a touch faster than automatic
  def admin?
    admin
  end

  def generate_api_key(created_by)
    if api_key.present?
      api_key.regenerate!(created_by)
      api_key
    else
      ApiKey.create(user: self, key: SecureRandom.hex(32), created_by: created_by)
    end
  end

  def revoke_api_key
    ApiKey.where(user_id: self.id).delete_all
  end

  def password=(password)
    @raw_password = password unless password.blank?
  end

  # Indicate that this is NOT a passwordless account for the purposes of validation
  def password_required!
    @password_required = true
  end

  def password_required?
    !!@password_required
  end

  def password
    '' # so that validator doesn't complain that a password attribute doesn't exist
  end

  protected

  def ensure_password_is_hashed
    if @raw_password
      self.salt = SecureRandom.hex(16)
      self.password_hash = hash_password(@raw_password, salt)
    end
  end

  def hash_password(password, salt)
    Pbkdf2.hash_password(password, salt, Rails.configuration.pbkdf2_iterations, Rails.configuration.pbkdf2_algorithm)
  end
end

# == Schema Information
#
# Table name: users
#
#  id            :uuid             not null, primary key
#  name          :string(255)
#  email         :string(255)      not null
#  password_hash :string(64)
#  salt          :string(32)
#  auth_token    :string(32)
#  admin         :boolean          default(FALSE), not null
#  active        :boolean          default(FALSE), not null
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_users_on_auth_token  (auth_token)
#  index_users_on_email       (email) UNIQUE
#  index_users_on_name        (name) UNIQUE
#
