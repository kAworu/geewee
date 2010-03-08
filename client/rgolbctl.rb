#!/usr/bin/env ruby
#  ____             _ _          _   _
# |  _ \ __ _  ___ | | |__   ___| |_| |
# | |_) / _` |/ _ \| | '_ \ / __| __| |
# |  _ < (_| | (_) | | |_) | (__| |_| |
# |_| \_\__, |\___/|_|_.__/ \___|\__|_|
#       |___/
#
# Rgolb client, see http://hg.kaworu.ch/rails-rgolb.
#
require 'yaml'
require 'rubygems'
require 'json'
require 'json/add/rails'

### stolen and hacked REST module {{{
#   from http://snipplr.com/view.php?codeview&id=2476
#
require 'net/https'
module REST

    # all HTTP methods supported
    Methods = [:GET, :POST, :PUT, :DELETE]

    class Connection
        def initialize(base_url, args = {})
            @base_url = base_url
            @username = args[:username]
            @password = args[:password]
        end

        def get(resource, args = nil)
            request(resource, :GET, args)
        end

        def post(resource, args = nil)
            request(resource, :POST, args)
        end

        def put(resource, args = nil)
            request(resource, :PUT, args)
        end
        def delete(resource, args = nil)
            request(resource, :DELETE, args)
        end

        protected
        def request(resource, method=:GET, args=nil)
            url = URI.join(@base_url, resource)

            if args
                # TODO: What about keys without value?
                url.query = args.map { |k,v| "%s=%s" % [URI.encode(k), URI.encode(v)] }.join("&")
            end

            case method
            when :GET
                req = Net::HTTP::Get.new(url.request_uri)
            when :POST
                req = Net::HTTP::Post.new(url.request_uri)
            when :PUT
                req = Net::HTTP::Put.new(url.request_uri)
            when :DELETE
                req = Net::HTTP::Delete.new(url.request_uri)
            end

            if @username and @password
                req.basic_auth(@username, @password)
            end

            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = (url.port == 443)

            res = http.start() { |conn| conn.request(req) }
            res.body
        end
    end
end
# }}}

### Resources {{{
# managable resources.
module Resources

    # resource auto detection.
    def self.detect rstr
        constants.each do |c|
            return eval c if c.downcase == rstr.downcase
        end if rstr
        nil
    end

    #
    # Category handler.
    #
    class Category
        # create a new Resources::Category with a connection object.
        def initialize conn
            @conn = conn
        end

        # return the Category list.
        def list
            JSON.parse(@conn.get('/categories.json'))
        end

        def handle action
            case action
            when 'list'
                l = self.list
                puts 'Categories List:'
                require "pp"
                l.each do |h|
                    c = h['category']
                    printf "\t%02d. %s\n", c['id'], c['display_name']
                end
            else
                if action
                    STDERR.puts <<-EOF
                        no action respond to `#{action}'
                    EOF
                    exit 1
                else
                    STDERR.puts "no action"
                end
            end
        end
    end
end
# }}}

### config and argument setup {{{
# basic config setup.
RgolbConfig = YAML.load(DATA.read)
unless RgolbConfig and RgolbConfig[:base_url]
    STDERR.puts 'Config is missing :base_url'
    exit 1
end

# find the resource wanted.
R = Resources::detect(rstr = ARGV.shift)
unless R
    STDERR.puts "invalid resource name: `#{rstr}'" if rstr
    STDERR.puts <<-EOF
    usage: #$0 [#{Resources.constants.join(' | ')}]
    EOF
    exit 1
end
r = R.new REST::Connection.new(RgolbConfig[:base_url], RgolbConfig)
r.handle(ARGV.shift)
# }}}


#
# Config for the client
#
__END__
---
:base_url:   "http://localhost:3000"
:user:       "kAworu"
:password:   "gou"
