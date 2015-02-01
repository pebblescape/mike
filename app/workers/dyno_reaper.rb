class DynoReaper
  include Sidekiq::Worker

  def perform(ids)
    Dyno.find(ids).each { |d| d.destroy }
    # TODO: logpoint
  end
end
