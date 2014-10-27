class PasswordValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    if value.nil?
      record.errors.add(attribute, :blank)
    elsif value.length < 8 # SiteSetting.min_password_length
      record.errors.add(attribute, :too_short, count: 8)
    # elsif SiteSetting.block_common_passwords && CommonPasswords.common_password?(value)
    #   record.errors.add(attribute, :common)
    end
  end

end
