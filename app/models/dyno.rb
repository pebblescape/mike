class Dyno < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :release

end

# == Schema Information
#
# Table name: dynos
#
#  id           :uuid             not null, primary key
#  app_id       :uuid
#  release_id   :uuid
#  type         :string(255)      not null
#  port         :integer
#  number       :integer
#  container_id :string(255)
#  ip_address   :inet
#  started_at   :datetime
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_dynos_on_app_id      (app_id)
#  index_dynos_on_release_id  (release_id)
#
