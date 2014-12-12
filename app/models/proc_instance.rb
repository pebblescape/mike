class ProcInstance < ActiveRecord::Base
  default_scope { order(:created_at) }

  belongs_to :app
  belongs_to :build
  belongs_to :user
  belongs_to :release

end

# == Schema Information
#
# Table name: proc_instances
#
#  id           :uuid             not null, primary key
#  user_id      :uuid
#  app_id       :uuid
#  build_id     :uuid
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
#  index_proc_instances_on_app_id      (app_id)
#  index_proc_instances_on_build_id    (build_id)
#  index_proc_instances_on_release_id  (release_id)
#  index_proc_instances_on_user_id     (user_id)
#
