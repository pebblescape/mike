class StaticController < ApplicationController
  skip_before_filter :redirect_to_login_if_required

  def show
    return redirect_to('/') if current_user && params[:id] == 'login'

    if I18n.exists?("static.#{@page}")
      render text: I18n.t("static.#{@page}"), layout: !request.xhr?, formats: [:html]
      return
    end
    
    @page = params[:id]

    file = "static/#{@page}.#{I18n.locale}"
    file = "static/#{@page}.en" if lookup_context.find_all("#{file}.html").empty?
    file = "static/#{@page}"    if lookup_context.find_all("#{file}.html").empty?

    if lookup_context.find_all("#{file}.html").any?
      render file, layout: !request.xhr?, formats: [:html]
      return
    end

    raise Mike::NotFound
  end
end
