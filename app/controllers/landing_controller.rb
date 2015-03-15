class LandingController < ApplicationController
  def index
    render file: "#{Rails.root}/public/index.html", layout: false
  end

end
