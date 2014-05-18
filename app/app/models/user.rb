require_dependency 'email'
require_dependency 'pbkdf2'
require_dependency 'mike'
require_dependency 'user_name_suggester'


class User < ActiveRecord::Base
  has_one :google_user_info, dependent: :destroy
  has_one :api_key, dependent: :destroy

  validates_presence_of :username
  validate :username_validator
  validates :email, presence: true, uniqueness: true
  validates :email, email: true, if: :email_changed?
  validate :password_validator

  before_save :update_username_lower
  before_save :ensure_password_is_hashed

  # excluding fake users like the system user
  scope :real, -> { where('id > 0') }

  def self.username_length
    SiteSetting.min_username_length.to_i..SiteSetting.max_username_length.to_i
  end

  def self.username_available?(username)
    lower = username.downcase
    User.where(username_lower: lower).blank?
  end

  EMAIL = %r{([^@]+)@([^\.]+)}

  def self.new_from_params(params)
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user.password = params[:password]
    user.username = params[:username]
    user
  end

  def self.suggest_name(email)
    return "" unless email
    name = email.split(/[@\+]/)[0]
    name = name.gsub(".", " ")
    name.titleize
  end

  # Find a user by temporary key, nil if not found or key is invalid
  def self.find_by_temporary_key(key)
    user_id = $redis.get("temporary_key:#{key}")
    if user_id.present?
      where(id: user_id.to_i).first
    end
  end

  def self.find_by_username_or_email(username_or_email)
    if username_or_email.include?('@')
      find_by_email(username_or_email)
    else
      find_by_username(username_or_email)
    end
  end

  def self.find_by_email(email)
    where(email: Email.downcase(email)).first
  end

  def self.find_by_username(username)
    where(username_lower: username.downcase).first
  end

  def change_username(new_username)
    self.username = new_username
    save
  end

  # Use a temporary key to find this user, store it in redis with an expiry
  def temporary_key
    key = SecureRandom.hex(32)
    $redis.setex "temporary_key:#{key}", 1.week, id.to_s
    key
  end

  def self.email_hash(email)
    Digest::MD5.hexdigest(email.strip.downcase)
  end

  def email_hash
    User.email_hash(email)
  end

  def password=(password)
    # special case for passwordless accounts
    @raw_password = password unless password.blank?
  end

  def password
    '' # so that validator doesn't complain that a password attribute doesn't exist
  end

  # Indicate that this is NOT a passwordless account for the purposes of validation
  def password_required!
    @password_required = true
  end

  def password_required?
    !!@password_required
  end

  def has_password?
    password_hash.present?
  end

  def password_validator
    PasswordValidator.new(attributes: :password).validate_each(self, :password, @raw_password)
  end

  def confirm_password?(password)
    return false unless password_hash && salt
    self.password_hash == hash_password(password, salt)
  end

  def seen_before?
    last_seen_at.present?
  end
  
  def update_ip_address!(new_ip_address)
    unless ip_address == new_ip_address || new_ip_address.blank?
      update_column(:ip_address, new_ip_address)
    end
  end

  def update_last_seen!(now=Time.zone.now)
    now_date = now.to_date
    # Only update last seen once every minute
    redis_key = "user:#{id}:#{now_date}"
    return unless $redis.setnx(redis_key, "1")

    $redis.expire(redis_key, SiteSetting.active_user_rate_limit_secs)
    update_previous_visit(now)
    # using update_column to avoid the AR transaction
    update_column(:last_seen_at, now)
  end

  def self.gravatar_template(email)
    email_hash = self.email_hash(email)
    "//www.gravatar.com/avatar/#{email_hash}.png?s={size}&r=pg&d=identicon"
  end

  # a touch faster than automatic
  def admin?
    admin
  end

  def username_format_validator
    UsernameValidator.perform_validation(self, 'username')
  end

  def readable_name
    return "#{name} (#{username})" if name.present? && name != username
    username
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

  def update_username_lower
    self.username_lower = username.downcase
  end

  def username_validator
    username_format_validator || begin
      lower = username.downcase
      existing = User.where(username_lower: lower).first
      if username_changed? && existing && existing.id != self.id
        errors.add(:username, I18n.t(:'user.username.unique'))
      end
    end
  end

  private

  def previous_visit_at_update_required?(timestamp)
    seen_before? && (last_seen_at < (timestamp - SiteSetting.previous_visit_timeout_hours.hours))
  end

  def update_previous_visit(timestamp)
    if previous_visit_at_update_required?(timestamp)
      update_column(:previous_visit_at, last_seen_at)
    end
  end
end
