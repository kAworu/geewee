require 'base64'

# Controller for static files management under the files/ directory.
#
#   * show and index are public via HTML UI.
#   * all but show and index are private via JSON API.
#
class StaticFilesController < ApplicationController
  STATIC_FILES_DIRECTORY = 'files'

  skip_before_filter :verify_authenticity_token

  # require auth for all methods but show and index.
  before_filter :require_author, :except => [:index, :show]

  # GET /static_files.json
  def index
    respond_to do |format|
      @files = Dir[File.join(local, '*')].collect do |path|
        remote(File.basename(path))
      end
      format.json { render :json => @files }
    end
  end

  # GET /static_files/bla.json
  def show
    respond_to do |format|
      format.json do
        if File.exist?(local(params[:id]))
          render :json => [remote(params[:id])]
        else
          render :json => nil, :status => 404 # 404 - HTTPNotFound
        end
      end
    end
  end

  # POST /static_files.json
  def create
    respond_to do |format|
      format.json do
        target = local(params[:name])
        if File.exist?(target)
          render :json => nil, :status => 409 # 409 - HTTPConflict
        else
          File.open(target, 'w') do |fd|
            fd << Base64::decode64(params[:data])
          end
          render :json => nil, :status => :created, :location => remote(params[:name])
        end
      end
    end
  end

  # PUT /static_files/1.json
  def update
    respond_to do |format|
      format.json do
        target = local(params[:id])
        unless File.exist?(target)
          render :json => nil, :status => 404 # 404 - HTTPNotFound
        else
          File.open(target, 'w') do |fd|
            fd << Base64::decode64(params[:data])
          end
          head :ok, :location => remote(params[:id])
        end
      end
    end
  end

  # DELETE /static_files/1.json
  def destroy
    @file = params[:id]

    respond_to do |format|
      format.json do
        unless File.exist?(local(@file))
          render :json => nil, :status => 404 # 404 - HTTPNotFound
        else
          begin
            File.delete(local(@file))
          rescue
            e = [['file', "could not delete #@file: #$!"]]
            render :json => e, :status => :unprocessable_entity
          else
            head :ok
          end
        end
      end
    end
  end

  private
  # give a filename, return the full remote path.
  def remote(path='')
    "#{GeeweeConfig.entry.bloguri}/#{STATIC_FILES_DIRECTORY}/#{path}"
  end

  # give a filename, return the locale path.
  def local(path='')
    File.join(Rails.root, 'public', STATIC_FILES_DIRECTORY, path)
  end
end
