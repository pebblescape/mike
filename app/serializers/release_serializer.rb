class ReleaseSerializer < ApplicationSerializer
  attributes :id, :app, :user, :build, :version, :description, :config_vars, :name

  def name
    "v#{object.version}"
  end

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

  def build
    {
      id: object.build.id,
      commit: object.build.commit,
      status: Build.status_types[object.build.status]
    }
  end
end
