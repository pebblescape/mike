class BuildSerializer < ApplicationSerializer
  attributes :id, :app, :user, :status, :buildpack_description, :commit, :process_types, :size, :created_at, :updated_at

  def user
    {
      id: object.user.id,
      email: object.user.email
    }
  end

  def app
    {
      id: object.app.id,
      name: object.app.name
    }
  end

  def status
    Build.status_types[object.status]
  end
end
