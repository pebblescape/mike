ActiveModel::Serializer.setup do |config|
  config.embed = :ids
  config.embed_in_root = true
end

# Disable for all serializers (except ArraySerializer)
ActiveModel::Serializer.root = false

# Disable for ArraySerializer
ActiveModel::ArraySerializer.root = false
