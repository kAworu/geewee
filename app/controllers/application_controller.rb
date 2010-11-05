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
      head :unauthorized
      return false
    end
  end

  # if Geewee hasn't been configured, render a help page :D
  CONFIG_ME_TEMPLATE = 'shared/config_me'
  def geewee_guide_steps
    if not GeeweeConfig.already_configured?
      render :file => CONFIG_ME_TEMPLATE, :layout => true
    end
  end
end
