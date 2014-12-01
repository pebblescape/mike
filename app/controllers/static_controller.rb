class StaticController < ApplicationController
  skip_before_filter :redirect_to_login_if_required, only: [:show]

  layout :set_layout

  def show
    return redirect_to('/') if current_user && params[:id] == 'login'

    # Don't allow paths like ".." or "/" or anything hacky like that
    @page = params[:id].gsub(/[^a-z0-9\_\-]/, '')

    file = "static/#{@page}.#{I18n.locale}"
    file = "static/#{@page}.en" if lookup_context.find_all("#{file}.html").empty?
    file = "static/#{@page}"    if lookup_context.find_all("#{file}.html").empty?

    if lookup_context.find_all("#{file}.html").any?
      render file, layout: !request.xhr?, formats: [:html]
      return
    end

    raise Mike::NotFound
  end

  private

  def set_layout
    params[:id] == 'login' ? 'no_js' : 'application'
  end
end
