#!/usr/bin/env ruby
#
#   __ _  ___  _____      _____  ___
#  / _` |/ _ \/ _ \ \ /\ / / _ \/ _ \
# | (_| |  __/  __/\ V  V /  __/  __/
#  \__, |\___|\___| \_/\_/ \___|\___|
#  |___/
#
# geewee client, see http://hg.kaworu.ch/rails-geewee.
#   this client need json in order to be able to use the geewee JSON API.
#
require 'fileutils'
require 'yaml'
require 'rubygems'

begin
  require 'json'
rescue LoadError => e
  STDERR.puts <<-EOF
  #{e.class}: #{e}

    this client need json in order to be able to use the geewee JSON API.
    please run:
        gem install json_pure
    or
        gem install json
  EOF
  exit 1
end

# Extending ruby for greater justice. {{{
#   some handy functions that would end in a utils.rb file.
#

F = File.basename($0)

# dynamic usage function.
def usage message
  STDERR.puts
  STDERR.puts "#{F}: #{message}"
  STDERR.puts
  STDERR.puts "usage: #{F} operation ressource [arguments...]"
  STDERR.puts
  STDERR.puts "CRUD operations:"
  STDERR.puts "===============>"
  STDERR.puts "\t#{F} create ressource"
  STDERR.puts "\t#{F} create ressource /path/to/file"
  STDERR.puts "\t#{F} show resource"
  STDERR.puts "\t#{F} show resource id"
  STDERR.puts "\t#{F} update ressource"
  STDERR.puts "\t#{F} update ressource id"
  STDERR.puts "\t#{F} update ressource id /path/to/file"
  STDERR.puts "\t#{F} destroy ressource"
  STDERR.puts "\t#{F} destroy ressource id"

  # Build the operation -> resource help.
  h = Hash.new
  ::Geewee::Client::Resources.all.each do |r|
    r.operations.keys.each do |op|
      (h[op] ||= Array.new) << r
    end
  end
  # and  display it
  STDERR.puts
  STDERR.puts "operations and resources:"
  STDERR.puts "========================>"
  h.each do |op, rs|
    rsstr = rs.collect { |r| r.resources.join('|') }.join(', ')
    STDERR.puts '- %10s: %s' % [op, rsstr]
  end
  exit
end

# really simple error familiy functions.
def info message
  puts "===> #{message}"
end

def warn message
  STDERR.puts "!!!> #{message}"
end

def err message
  STDERR.puts "#{F}: #{message}"
  exit 1
end

def debug message
  STDERR.puts message if $DEBUG
end

# ask the user.
def ask question
  STDOUT.print "???> #{question}"
  STDOUT.flush
  STDIN.gets.chomp
end

# ask the user to answer by yes or no.
def yesno question
  ans = String.new
  until ans =~ /^\s*(?:y(?:es)?|no?)\s*$/i
    ans = ask(question + '? [y/n]: ')
  end
  ans =~ /y(?:es)?/
end

# Object#instance_eval can't pass arguments to the block. Ruby 1.9 will define
# Object#instance_exec but for 1.8 we hack it.
#   see http://www.ruby-forum.com/topic/54096.
class Object
  def instance_exec(*args, &block)
    mname = "__instance_exec_#{Thread.current.object_id.abs}"
    class << self; self end.class_eval{ define_method(mname, &block) }
    begin
      ret = send(mname, *args)
    ensure
      class << self; self end.class_eval{ undef_method(mname) } rescue
      nil
    end
    ret
  end
end if RUBY_VERSION < '1.9.0'
# }}}

# My Shiny Geewee module <3
module Geewee
module Client

# stolen and hacked REST module {{{
#   from http://snipplr.com/view.php?codeview&id=2476
#
module REST
  require 'net/https'
  # all REST methods.
  Methods = {
      :GET    => Net::HTTP::Get,
      :POST   => Net::HTTP::Post,
      :PUT    => Net::HTTP::Put,
      :DELETE => Net::HTTP::Delete,
  }

  # HTTP connection handler class.
  # args can contains :username and :password key faut http basic auth.
  # args can contains :default_arg hash that will be sent for each request of
  #   this connection.
  # Example:
  #   REST::Connection.new 'http://my.sexy/url',
  #     :username => 'satan',
  #     :password => '666',
  #     :default_args => {:destination => 'Hell'}
  class Connection
    def initialize(base_url, args=Hash.new)
      @base_url = base_url
      @username = args[:username]
      @password = args[:password]
      @default_args = args[:default_args] || Hash.new
    end

    # send the HTTP request, method_sym should be a key of Methods.
    def request(method_sym, resource, args=nil)
      args = @default_args.merge(args || Hash.new)
      url  = URI.join(@base_url, resource)

      method = Methods[method_sym]
      if method::REQUEST_HAS_BODY
        req = method.new(url.request_uri)
        req.form_data = args
      else
        url.query = args.collect do |k,v|
          URI.encode(k.to_s) + (v.nil? ? '' : '=' + URI.encode(v.to_s))
        end.join('&')
        req = method.new(url.request_uri)
      end

      if @username and @password
        req.basic_auth(@username, @password)
      end

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = (url.port == 443)

      $stderr.puts "#{method_sym} #{url}" if $DEBUG
      http.start { |conn| conn.request(req) }
    end
  end
end
# }}}

# Resources module and bases classes {{{
#   modules and functions used to implements Resources management.
#

# contains all Resources and find them.
module Resources
  # This is where all Resources classes belongs.
  module All end

  # return all Resources in the All module, as Class objects.
  def self.all
    self::All.constants.collect { |const| eval "self::All::#{const}" }
  end

  # Auto-detect available resources.
  #   target argument must be a symbol.
  def self.detect target
    all.each do |klass|
      return klass if klass.resources.include?(target)
    end
    nil # couldn't find it!
  end
end

# Base class for Resources.
class Resources::Base
  All = [:create, :show, :update, :destroy]

  # raised when an operation is not supported by a ressource instance.
  class BadOperation < Exception
  end

  # conn is a REST::Connection instance.
  def initialize conn
    @conn = conn
  end

  # Array of name matching this Resource.
  #   it's composed of symbols like [:category, :categories] that are alias.
  def self.resources
    # NOTE: the current context is class, so it is a class instance
    #       variable.
    @resources ||= Array.new
  end

  # Hash of supported operations for this class.
  #   it's a Hash from operations keys (like :show) to lambda functions that
  #   take two arguments, id and file (that can be nil).
  def self.operations
    # NOTE: the current context is class, so it is a class instance
    #       variable.
    @operations ||= Hash.new
  end

  # Do the given action if possible.
  def apply h
    ops = self.class.operations
    unless ops.key?(h[:operation])
      raise BadOperation.new("#{h[:operation]}: operation not supported by #{self.class}")
    else
      f = ops[h[:operation]]
      instance_exec(h, &f)
    end
  end

  # declare aliases for the resource.
  def self.alias_resource *list
    (resources << list).flatten!
  end

  protected

  # declare which name this resource is responsible for, used for HTTP request.
  def self.resource
    @resource
  end
  def self.named_resource name
    @resource = name
  end

  # declare which operations are accepted.
  def self.accept(op, &block)
    operations[op] = block
  end

  # used to format validation messages from JSON on error.
  # this method does not raise, just return the RequestError.
  def requesterrorize(json)
    msg = JSON.parse(json).collect { |e| e.join(' ') }.join(', ')
    RequestError.new(msg)
  end

  def generic_destroy h
    id = h[:argv].first rescue nil
    unless id
      # show and ask for id.
      self.apply :operation => :show
      id = ask("target id to destroy: ")
    end
    self.apply :operation => :show, :argv => [id]
    if yesno('destroy')
      case response = delete(id) when ::Net::HTTPOK
        info 'destroyed.'
      else
        raise requesterrorize(response.body)
      end
    end
  end

  # helpers for HTTP request.
  def get(id=nil, args=nil)
    request(:GET, id, args)
  end
  def post(id=nil, args=nil)
    request(:POST, id, args)
  end
  def put(id=nil, args=nil)
    request(:PUT, id, args)
  end
  def delete(id=nil, args=nil)
    request(:DELETE, id, args)
  end

  private

  def request(method, id, args)
    if id and not args and id.is_a?(Hash)
      args = id
      id = nil
    end
    resource =  '/' + self.class.resource.to_s
    resource << "/#{id}" if id
    resource << '.json'
    @conn.request(method, resource, args)
  end
end

# Resource File
#   Handle a human readable Resource description.
#   RFile looks like email, a header of key:values, an empty line and a body.
class RFile
  # RFile exceptions classes.
  class Error < StandardError
  end
  class ParseError < Error
  end

  attr_accessor :head, :body, :path

  # crate a new RFile with a path to load.
  def self.load(path)
    rf = RFile.new
    rf.path = path
    rf.parse!
  end

  # create a new RFile.
  #   if head is an Array, it is a list of empty header keys.
  def initialize(head=nil)
    @head = Hash.new
    head.each { |k,v| @head[k] = v } if head
    @body = String.new
  end

  # parse a file argument, if `-' STDIN is used.
  def parse!
    fd    = if @path == '-' then STDIN else File.open(@path) end
    data  = fd.read
    @head = Hash.new
    @body = String.new

    parse_head = true
    data.split("\n").each do |line|
      if parse_head
        if line.empty?
          parse_head = false
        elsif line =~ /^(.+?):(.*)$/
          @head[$1.strip] = $2.strip
        else
          raise ParseError.new("#@path: bad RFile header line: #{line}")
        end
      else
        @body << line << "\n"
      end
    end
    self
  end

  def to_s
    s = String.new
    @head.each { |k,v| s << "#{k}: #{v}\n" }
    s << "\n"
    s << @body
  end

  # call editor to edit self. return self if all went well, raise a
  # RuntimeError if the editor returned a non-zero status.
  def edit!
    @path = "/tmp/#{F}_#{Time.now.to_i}#$$"
    File.open(@path, 'w') { |fd| fd << self.to_s }
    if system "#{$config['editor']} #@path" then
      self.parse!
      # the file was temporary for geewee use, we can remove it safely now.
      File.delete(@path)
      self
    else
      raise Error.new("editor aborded (file was #{@path})")
    end
  end
end


# raised when the server return a request error.
class RequestError < StandardError
  attr_reader :response, :rfile

  def initialize(response, rfile=nil)
    @response = response
    @rfile    = rfile
  end

  def to_s
    s = super + ": #@response"
    s << " (file was #{@rfile.path})" rescue s
  end
end
# }}}

# Category Resource {{{
#   show, create, edit and destroy operations are allowed.
#
class Resources::All::Category < Resources::Base
  private
  # keys for the geewee API.
  module Keys
    DISPLAY_NAME = '[category]display_name'
  end

  named_resource :categories
  alias_resource :categories

  # always display a list of Category.
  #   show categories
  #   show categories id
  accept :show do |h|
    id = h[:argv].first rescue nil

    case response = get(id) when ::Net::HTTPOK
      if id
        cs = [JSON.parse(response.body)]
      else
        cs = JSON.parse(response.body)
      end
      cs.each { |h| display h['category'] }
    else
      raise RequestError.new(response)
    end
  end

  # create a new category.
  #   generate a stub file and call editor:
  #       create categories
  #   load from STDIN:
  #       create categories -
  #   load from file:
  #       create categories /path/to/stub/file
  accept :create do |h|
    file = h[:argv].first rescue nil
    rf = if file
           RFile.load(file)
         else
           RFile.new([Keys::DISPLAY_NAME]).edit!
         end
    case response = post(rf.head) when ::Net::HTTPCreated
      info 'new Category created:'
      display JSON.parse(response.body)['category']
    else
      raise requesterrorize(response.body)
    end
  end

  # update a category.
  #   update categories
  #   update categories 1
  #   update categories 1 /path/to/file
  accept :update do |h|
    h[:argv] ||= Array.new

    unless id = h[:argv].shift
      # show categories and ask for id.
      self.apply  :operation => :show
      id = ask('target Category id to update: ')
    end
    case response = get(id) when ::Net::HTTPOK
      c = JSON.parse(response.body)['category']
    else
      raise RequestError.new(response)
    end
    rf = if file = h[:argv].shift
           RFile.load(file)
         else
           RFile.new(Keys::DISPLAY_NAME => c['display_name']).edit!
         end
    case response = put(c['id'], rf.head) when ::Net::HTTPOK
      info 'Category updated.'
    else
      raise requesterrorize(response.body)
    end
  end

  # destroy a category.
  #   destroy categories
  #   destroy categories 1
  accept(:destroy) { |h| generic_destroy(h) }

  # print category on stdout
  def display c
    puts '%3d. %s (%d)' % [c['id'], c['display_name'], c['posts'].size]
  end
end
# }}}

# Posts Resource {{{
#   show, create, update and destroy operations are allowed.
#   has a publish operation to switch the published flags in a more easy way
#   than update and edit.
#
class Resources::All::Post < Resources::Base
  private
  # for displaying and asking category on create.
  Category = Resources::All::Category

  # keys for the geewee API.
  module Keys
    TITLE     = '[post]title'
    TAGS      = '[post]tag_list'
    PUBLISHED = '[post]published'
    CATEGORY  = '[post]category_id'
    INTRO     = '[post]intro'
    BODY      = '[post]body'
  end

  named_resource :posts
  alias_resource :posts

  # display a list of posts, or a post.
  #   show posts
  #   show posts id
  accept :show do |h|
    id = h[:argv].first rescue nil

    case response = get(id) when ::Net::HTTPOK
      if id
        display JSON.parse(response.body)['post']
      else
        JSON.parse(response.body).reverse.each do |h|
          post = h['post']
          pubstr = (post['published'] ? '' : '[unpublished] ')
          print '%3d. %s"%s"' % [post['id'], pubstr, post['title']]
          puts ' by %s in %s (%s)' % [post['author']['name'],
            post['category']['display_name'], tags_to_s(post['tags'])]
        end
      end
    else
      raise RequestError.new(response)
    end
  end

  # create a new post.
  #   generate a stub file and call editor:
  #       create posts
  #   load from STDIN:
  #       create posts -
  #   load from file:
  #       create posts /path/to/stub/file
  accept :create do |h|
    file = h[:argv].first rescue nil
    if file
      rf = RFile.load(file)
    else
      rf = stubize.edit!
      rf.head[Keys::PUBLISHED] = (yesno('publish now') ? '1' : '0')
    end
    fill_intro_n_body(rf)
    case response = post(rf.head) when ::Net::HTTPCreated
      info "new Post created: #{response['Location']}"
    else
      raise requesterrorize(response.body)
    end
  end

  # update a post.
  #   update posts
  #   update posts 1
  #   update posts 1 /path/to/file
  accept :update do |h|
    h[:argv] ||= Array.new

    unless id = h[:argv].shift
      # show posts and ask for id.
      self.apply  :operation => :show
      id = ask('target Post id to update: ')
    end
    case response = get(id) when ::Net::HTTPOK
      p = JSON.parse(response.body)['post']
    else
      raise RequestError.new(response)
    end

    if file = h[:argv].shift
      rf = RFile.load(file)
    else
      rf = RFile.new Keys::TITLE      => p['title'],
                     Keys::TAGS       => tags_to_s(p['tags']),
                     Keys::PUBLISHED  => (p['published'] ? '1' : '0'),
                     Keys::CATEGORY   => p['category_id']
      rf.body = p['intro']
      rf.body << "%...\n" << p['body'] if p['body']
      rf.edit!
    end
    fill_intro_n_body(rf)

    case response = put(p['id'], rf.head) when ::Net::HTTPOK
      info "Post updated: #{response['Location']}"
    else
      requesterrorize(response.body)
    end
  end

  # destroy a post.
  #   destroy posts
  #   destroy posts 1
  accept(:destroy) { |h| generic_destroy(h) }

  # publish a post.
  #   publish posts
  #   publish posts 1
  accept :publish do |h|
    id = h[:argv].first rescue nil
    unless id
      # show posts and ask for id.
      self.apply :operation => :show
      id = ask('target Post id to publish: ')
    end
    case response = put("publish/#{id}") when ::Net::HTTPOK
      info 'published.'
    else
      requesterrorize(response.body)
    end
  end

  # print post on stdout
  def display post
    puts "created_at: #{post['created_at']}"
    puts "updated_at: #{post['updated_at']}"
    puts "id:       #{post['id']}"
    puts "author:   #{post['author']['name']}"
    puts "category: #{post['category']['display_name']}"
    puts "tags:     #{tags_to_s(post['tags'])}"
    puts "title:    #{post['title']}"
    puts
    puts post['intro']
    puts "\n%...\n" + post['body'] if post['body']
  end

  # pretty print of tags.
  def tags_to_s tags
    tags.collect { |t| t['name'] }.join(', ')
  end

  # create a stub RFile.
  def stubize
    cid = String.new
    c = Category.new(@conn)
    c.apply :operation => :show
    until cid =~ /^\d+$/
      cid = ask('Choose a Category id (n to create a new one): ')
      if cid == 'n'
        c.apply :operation => :create rescue warn $!
        c.apply :operation => :show
      end
    end
    head = {
      Keys::TITLE     => nil,
      Keys::TAGS      => nil,
      Keys::CATEGORY  => cid
    }
    rf = RFile.new(head)
    rf.body << "*Intro*\n\n%...\n\n*Body*"
    rf
  end

  # parse rf.body to split into the intro and body part of the post.
  def fill_intro_n_body rf
    s = rf.body
    rf.body = ""
    a = s.split(/^%\.\.\.\s*$/)
    rf.head[Keys::INTRO] = a[0]
    rf.head[Keys::BODY]  = a[1]
  end
end
# }}}

# Static Page Resource {{{
#   show, create, update and destroy operations are allowed.
#
class Resources::All::Page < Resources::Base
  private

  # keys for the geewee API.
  module Keys
    TITLE = '[page]title'
    BODY  = '[page]body'
  end

  named_resource :pages
  alias_resource :pages

  # display the list of pages.
  #   show pages
  #   show pages id
  accept :show do |h|
    id = h[:argv].first rescue nil

    case response = get(id) when ::Net::HTTPOK
      if id
        page = JSON.parse(response.body)['page']
        puts "id: #{page['id']}"
        puts "created_at: #{page['created_at']}"
        puts "updated_at: #{page['updated_at']}"
        puts "title:      #{page['title']}"
        puts "subtitle:   #{page['subtitle']}"
        puts
        puts page['body']
      else
        JSON.parse(response.body).each do |page|
          p = page['page']
          puts '%3d. %s' % [p['id'], p['title']]
        end
      end
    else
      raise RequestError.new(response)
    end
  end

  # create a new page.
  #   generate a stub file and call editor:
  #       create pages
  #   load from STDIN:
  #       create pages -
  #   load from file:
  #       create pages /path/to/stub/file
  accept :create do |h|
    file = h[:argv].first rescue nil
    rf = if file
           RFile.load(file)
         else
           RFile.new([Keys::TITLE]).edit!
         end
    fill_body(rf)

    case response = post(rf.head) when ::Net::HTTPCreated
      info "new Post created: #{response['Location']}"
    else
      requesterrorize(response.body)
    end
  end

  # update a page.
  #   update pages
  #   update pages 1
  #   update pages 1 /path/to/file
  accept :update do |h|
    h[:argv] ||= Array.new

    unless id = h[:argv].shift
      # show page and ask for id.
      self.apply  :operation => :show
      id = ask('target Page id to update: ')
    end
    case response = get(id) when ::Net::HTTPOK
      p = JSON.parse(response.body)['page']
    else
      raise RequestError.new(response)
    end

    if file = h[:argv].shift
      rf = RFile.load(file)
    else
      rf = RFile.new(Keys::TITLE => p['title'])
      rf.body = p['body']
      rf.edit!
    end
    fill_body(rf)

    case response = put(p['id'], rf.head) when ::Net::HTTPOK
      info "Page updated: #{response['Location']}"
    else
      requesterrorize(response.body)
    end
  end

  # destroy a page.
  #   destroy pages
  #   destroy pages 1
  accept(:destroy) { |h| generic_destroy(h) }

  # load the body into the proper header key.
  def fill_body rf
    rf.head[Keys::BODY] = rf.body
    rf.body             = ""
  end
end
# }}}

# Comment Resource {{{
#   Manage blog comments. Only show and destroy are available, but a next
#   operation give the next unread comment.
#
class Resources::All::Comment < Resources::Base
  private

  named_resource :comments
  alias_resource :comments

  # display the list of comments.
  #   show comments
  #   show comments id
  accept :show do |h|
    id = h[:argv].first rescue nil

    case response = get(id) when ::Net::HTTPOK
      if id
        comment = JSON.parse(response.body)['comment']
        display(comment)
      else
        JSON.parse(response.body).each do |comment|
          c = comment['comment']
          puts '%3d[%s] by %s on %s' % [c['id'], (c['read'] ? '-' : '!'), c['name'], c['post']['title']]
        end
      end
    else
      raise RequestError.new(response)
    end
  end

  # display and mark as read the next unread comment.
  #   next comments
  #   next comments id
  accept :next do |h|
    case response = put('next_unread') when ::Net::HTTPOK
      comment = JSON.parse(response.body)['comment']
      display(comment)
    when ::Net::HTTPNoContent
      info 'no new comments.'
    else
      raise RequestError.new(response)
    end
  end

  # destroy a comment.
  #   destroy comments
  #   destroy comments 1
  accept(:destroy) { |h| generic_destroy(h) }

  def display comment
    comment_uri = "#{$config['base_url']}/posts/#{comment['post_id']}#comment_#{comment['id']}"
    puts "id: #{comment['id']}"
    puts "created_at: #{comment['created_at']}"
    puts "on post:    #{comment['post']['title']}"
    puts "link:       #{comment_uri}"
    puts "status:     #{if comment['read'] then 'readed' else 'new' end}"
    puts "author:     #{comment['name']}"
    puts "  email:    #{comment['email']}"
    puts "  website:  #{comment['url']}" if (comment['url'] and comment['url'].size > 0)
    puts
    puts comment['body']
end
end
# }}}

# Authors Resource {{{
# Only index and update are allowed, and can affect only the current user.
#
class Resources::All::Authors < Resources::Base
  private

  # keys for the geewee API.
  module Keys
    NAME   = '[author]name'
    EMAIL  = '[author]email'
    EDITOR = '[author]editor'
  end

  named_resource :authors
  alias_resource :author, :me

  # display the current author.
  #   show authors|me
  accept :show do |h|
    case response = get when ::Net::HTTPOK
      author = JSON.parse(response.body)['author']
      puts "name:   #{author['name']}"
      puts "email:  #{author['email']}"
      puts "editor: #{author['editor']}"
    else
      raise RequestError.new(response)
    end
  end

  # update the current author.
  #   update authors|me
  accept :update do |h|
    case response = get when ::Net::HTTPOK
      me = JSON.parse(response.body)['author']
    else
      raise RequestError.new(response)
    end

    if file = h[:argv].shift
      rf = RFile.load(file)
    else
      rf = RFile.new Keys::NAME   => me['name'],
        Keys::EMAIL  => me['email'],
        Keys::EDITOR => me['editor']
      rf.edit!
    end
    case response = put(me['id'], rf.head) when ::Net::HTTPOK
      info 'Authors info updated!'
      if rf.head[Keys::EDITOR] != me['editor']
        warn 'Your editor setting has been changed, update your client script.'
      end
    else
      requesterrorize(response.body)
    end
  end
end
#}}}

# Client Resource {{{
# fake ressource, to auto update the client script.
#
class Resources::All::Client < Resources::Base
  private

  # special ressource
  named_resource :authors # what a hack ;)
  alias_resource :client

  # auto update the current client
  #   update gclient
  accept :update do |h|
    me = __FILE__
    case response = get('client/update') when ::Net::HTTPOK
      neo = JSON.parse(response.body)['client']
      if File.read(me) == neo
        info 'Already up to date.'
      else
        bak = "/tmp/#{File.basename me}.bak"
        info "creating a backup file at #{bak}"
        FileUtils.cp(me, bak)
        info "updating #{me}..."
        File.open(me, 'w') { |fd| fd << neo }
        info 'done!'
      end
    else
      raise RequestError.new(response)
    end
  end
end
#}}}

# File Resource {{{
# handle static files.
#
class Resources::All::File < Resources::Base
  require 'base64'
  private

  # special ressource
  named_resource :static_files
  alias_resource :files

  # display all the static files.
  #   show files
  accept :show do |h|
    id = h[:argv].first rescue nil
    id = File.basename(id) unless id.nil?

    case response = get(id) when ::Net::HTTPOK
      files = JSON.parse(response.body)
      if files.size == 0
        info 'No files.'
      else
        files.each { |f| puts f }
      end
    when ::Net::HTTPNotFound
      info "#{id}: Not found."
    else
      raise RequestError.new(response)
    end
  end

  accept :create do |h|
    target = check_target(h)
    bname  = File.basename(target)
    case get(bname) when ::Net::HTTPOK
      raise RequestError.new("#{bname}: file already exist, use update.")
    end

    info "uploading #{target}..."
    response = post :name => bname,
      :data => Base64::encode64(File.read(target))
    case response when ::Net::HTTPCreated
      info "completed: #{response['Location']}"
    else
      raise RequestError.new(response)
    end
  end

  accept :update do |h|
    target = check_target(h)
    bname  = File.basename(target)
    case get(bname) when ::Net::HTTPNotFound
      raise RequestError.new("#{bname}: file does not exist, use create.")
    end

    info "uploading #{target}..."
    response = put(bname, :data => Base64::encode64(File.read(target)))
    case response when ::Net::HTTPOK
      info "completed: #{response['Location']}"
    else
      raise RequestError.new(response)
    end
  end

  accept :destroy do |h|
    target = h[:argv].first
    raise BadOperation.new('need a file argument') if target.nil?
    bname  = File.basename(target)

    case response = delete(bname) when ::Net::HTTPOK
      info "#{bname}: destroyed."
    when ::Net::HTTPNotFound
      raise RequestError.new("#{bname}: file does not exist.")
    else
      raise RequestError.new(response)
    end
  end

  # check if the target file exist.
  def check_target(h)
    target = h[:argv].first
    raise BadOperation.new('need a file argument') if target.nil?
    raise Errno::ENOENT.new(target) unless File.exist?(target)
    target
  end
end
# }}}
end # end of Client module.
end # end of Geewee module.


# main procedure called if this script is executed.
def main
  include ::Geewee::Client

  $config = YAML.load(DATA.read)
  unless $config['editor'] or $config['editor'] = ENV['EDITOR']
    err "please set $EDITOR in env."
  end

  if ARGV.size < 2
    usage 'wrong # of arguments'
    exit 1
  end

  operation = ARGV.shift
  resource  = ARGV.shift
  argv      = ARGV

  # find the resource wanted.
  rclass = Resources::detect(resource.downcase.to_sym)
  usage "couldn't find resource #{resource}" unless rclass
  conn = REST::Connection.new($config['base_url'],
    :default_args => {:geewee_api_key => $config['geewee_api_key'], :locale => :en})
  r = rclass.new(conn)
  begin
    r.apply :operation => operation.downcase.to_sym, :argv => argv
  rescue Resources::Base::BadOperation
    usage $!
  rescue Errno::ECONNREFUSED
    err "#{$config['base_url']} #$!"
  rescue RequestError, RFile::Error, Errno::EEXIST
    err $!
  rescue Interrupt
    puts
    warn 'Interupted! bye bye.'
  end
end
main if $0 == __FILE__


###
# Config for the geewee client in YAML, example:
=begin

---
base_url:       http://my.sexy.geewee/blog/path
editor:         vi
geewee_api_key: my_secret_single_access_token

=end

__END__
