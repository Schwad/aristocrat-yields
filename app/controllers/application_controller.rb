class ApplicationController < ActionController::Base
  before_action :authenticate
  protect_from_forgery with: :exception

  def authenticate
    unless Rails.env.development? || Rails.env.testing?
      authenticate_or_request_with_http_basic('Administration') do |username, password|
        username == Figaro.env.username && password == Figaro.env.custom_login_key
      end
    end
  end
end
