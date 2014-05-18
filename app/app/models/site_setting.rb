require 'site_setting_extension'
require_dependency 'site_settings/yaml_loader'

class SiteSetting < ActiveRecord::Base
  extend SiteSettingExtension

  validates_presence_of :name
  validates_presence_of :data_type

  def self.load_settings(file)
    SiteSettings::YamlLoader.new(file).load do |category, name, default, opts|
      if opts.delete(:client)
        client_setting(name, default, opts.merge(category: category))
      else
        setting(name, default, opts.merge(category: category))
      end
    end
  end

  load_settings(File.join(Rails.root, 'config', 'site_settings.yml'))

  client_settings << :available_locales

  def self.available_locales
    LocaleSiteSetting.values.map{ |e| e[:value] }.join('|')
  end

  def self.scheme
    use_https? ? "https" : "http"
  end
  
end
