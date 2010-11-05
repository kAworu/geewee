# Help, some user-friendly static files.
#
class HelpController < ApplicationController
  def unauthorized
    render :status => :unauthorized
  end
end
