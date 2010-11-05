# Help, some user-friendly static files.
#
class HelpController < ApplicationController
  def unauthorized
    render :nothing
  end
end
