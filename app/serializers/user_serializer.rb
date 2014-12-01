class UserSerializer < ApplicationSerializer
  attributes :id, :login, :email, :active
end
