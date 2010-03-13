# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  helper_method :check_single_access_token, :current_author, :require_author
  before_filter :check_single_access_token

  private

  # find the current author.
  def check_single_access_token
    if params[:geewee_api_key]
      @current_author = Author.find_by_single_access_token(params[:geewee_api_key])
    end
  end

  def current_author
    return @current_author if defined?(@current_author)
    nil
  end

  # filter method to require auth.
  def require_author
    unless current_author
      head :unauthorized
      return false
    end
  end
end
