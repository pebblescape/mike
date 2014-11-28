class AppSerializer < ApplicationSerializer
  attributes :id, :name, :owner

  def owner
    {
      id: object.owner.id,
      email: object.owner.email
    }
  end
end
