class DynoReaper
  include Sidekiq::Worker

  def perform(ids)
    Dyno.where(id: ids).each(&:destroy)
    # TODO: logpoint
  end
end
