class PushSerializer < ReleaseSerializer
  attributes :url

  def url
    'fake'
  end
end
