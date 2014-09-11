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