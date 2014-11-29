class AppSerializer < ApplicationSerializer
  attributes :id, :name, :owner, :created_at, :updated_at, :config_vars

  def owner
    {
      id: object.owner.id,
      email: object.owner.email
    }
  end
end
