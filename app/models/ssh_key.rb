require 'digest/md5'
require 'base64'

class SshKey < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :key
  
  before_save :generate_fingerprint
  
  PUBRE = /^(ssh-[dr]s[as]\s+)|(\s+.+\@.+)|\n/
  COLONS = /(.{2})(?=.)/
  
  def generate_fingerprint
    pubkey = self.key.clone.gsub!(PUBRE, '')
    pubkey = Digest::MD5.hexdigest(Base64.decode64(pubkey))
    self.fingerprint = pubkey.gsub!(COLONS, '\1:')
  end
end

# == Schema Information
#
# Table name: ssh_keys
#
#  id          :uuid             not null, primary key
#  user_id     :uuid
#  key         :text             not null
#  created_at  :datetime
#  updated_at  :datetime
#  fingerprint :string(255)      not null
#
# Indexes
#
#  index_ssh_keys_on_fingerprint  (fingerprint)
#  index_ssh_keys_on_key          (key)
#  index_ssh_keys_on_user_id      (user_id)
#
