class EmptyWorker
  include Sidekiq::Worker

  def perform(ids)

  end
end
