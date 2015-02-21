class DynoReaper
  include Sidekiq::Worker

  def perform(ids)
    Dyno.where(id: ids).each { |d| d.destroy }
    # TODO: logpoint
  end
end
