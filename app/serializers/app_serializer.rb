class AppSerializer < ApplicationSerializer
  attributes :id, :name, :owner_id, :created_at, :updated_at, :config_vars, :build_size, :web_url

  def owner
    {
      id: object.owner.id,
      email: object.owner.email,
      name: object.owner.name
    }
  end

  def build_size
    object.builds.last.try(:size)
  end

  def web_url
    "http://#{object.hostname}"
  end
end
