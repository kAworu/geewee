# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  before_filter :check_single_access_token, :set_locale, :geewee_guide_steps
  helper_method :check_single_access_token, :set_locale,
                :current_author, :require_author, :geewee_guide_steps

  private
  def set_locale
    I18n.locale = GeeweeConfig.entry.locale.try(:to_sym)
    I18n.locale = params[:locale] if GeeweeConfig::ACCEPTED_LOCALES.include?(params[:locale])
  end

  # find the current author.
  def check_single_access_token
    if params[:geewee_api_key]
      @current_author = Author.find_by_single_access_token(params[:geewee_api_key])
    end
  end

  # method used by authlogic.
  def current_author
    return @current_author if defined?(@current_author)
    nil
  end

  # filter method to require auth.
  def require_author
    unless current_author
      redirect_to unauthorized_path
      false
    end
  end

  # help the user through the installation process.
  def geewee_guide_steps
    unless GeeweeConfig.already_configured? or params[:controller] == 'help'
      redirect_to config_path
      false
    end
  end
end
