task :stats => "geewee:statsetup"

namespace :geewee do
  # Setup geewee client for stats
  task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(Geewee\ Client client)
    ::STATS_DIRECTORIES << %w(Client\ features client/features) if File.exist?('client/features')
    ::CodeStatistics::TEST_TYPES << "Client features" if File.exist?('client/features')
    ::STATS_DIRECTORIES << %w(Client\ specs client/spec) if File.exist?('client/spec')
    ::CodeStatistics::TEST_TYPES << "Client specs" if File.exist?('client/spec')
  end

  def ask(question, opts=Hash.new)
    answer = nil
    begin
      print "???> #{question}"
      print " [#{opts[:default]}]" if opts[:default]
      print ": "
      if (get = STDIN.gets.chomp) =~ /^\s*$/ and opts[:default]
        answer = opts[:default]
      else
        answer = get
      end
    end while answer.blank? and not opts[:allow_blank]
    answer
  end

  desc "print on STDERR the geewee client file. Need AUTHOR=name"
  task :client => :environment do
    name = ENV['AUTHOR']
    if name.blank?
      STDERR.puts '!!!> this task need the AUTHOR env variable.'
      exit 1
    end
    STDERR.puts Author.find(name).client!
  end

  desc "create a new Author"
  task :new_author => :environment do
    I18n.locale = :en
    author = nil
    until author and author.valid?
      if author.nil?
        author = Author.new
      else
        puts "- #{author.errors.map { |err| err.join(' ') }.join("\n- ")}"
        puts "---> don't worry, try again :)"
      end
        author.name   = ask("author's nickname")
        author.email  = ask("author's email (don't lie, used only for gravatar)")
        author.editor = ask("finally, what is your favourite editor? (for example, mine is vim. If blank $EDITOR will be used)", :allow_blank => true)
    end
    author.save!
    puts "Ok #{author.name}'s account has been created!"

    clientpath = "tmp/geewee_#{author.name}"
    File.open(clientpath, "w") { |fd| fd << author.client! }
    File.chmod(0700, clientpath)
    puts "!!!> IMPORTANT: your client script is here: #{clientpath}"
  end

  desc "edit or create the geewee configuration"
  task :config => :environment do
    I18n.locale = :en

    c = if GeeweeConfig.already_configured?
          GeeweeConfig.entry
        else
          GeeweeConfig.new :post_count_per_page => 5, :locale => 'en'
        end
    c.bloguri = ask("What is your geewee url? (for example, mine is http://blog.kaworu.ch)", :default => c.bloguri)
    # fix URL to require http://
    c.bloguri = "http://#{c.bloguri}" unless c.bloguri =~ %r{^http://}
    c.blogtitle    = ask("Enter the blog's title", :default => c.blogtitle)
    c.blogsubtitle = ask("Enter the blog's subtitle (leave empty for none)", :default => c.blogsubtitle, :allow_blank => true)
    i = c.post_count_per_page
    begin
      i = ask("how many posts per page do you want to display?", :default => c.post_count_per_page).to_i
    end until i > 0
    c.post_count_per_page = i
    puts <<-EOF

reCAPTCHA (http://www.google.com/recaptcha) is a free anti-bot service. You
should definitively use it, but since it require to sign up it's not mandatory
to run geewee. If you want to use it, click here to signup (it only require
your hostname):
  http://www.google.com/recaptcha/whyrecaptcha
    EOF
    if ask("do you want to use recaptcha? (recommended!)", :default => 'yes') =~ /^\s*y(?:es)?\s*$/
      c.use_recaptcha = true
      c.recaptcha_private_key = ask("reCAPTCHA private key", :default => c.recaptcha_private_key)
      c.recaptcha_public_key = ask("reCAPTCHA public key", :default => c.recaptcha_public_key)
    else
      c.use_recaptcha = false
      c.recaptcha_private_key = c.recaptcha_public_key = nil
      c.recaptcha_private_key = c.recaptcha_public_key = nil
    end

    l = c.locale
    begin
      l = ask("What should be the blog locale? (#{GeeweeConfig::ACCEPTED_LOCALES.join(', ')})", :default => c.locale)
    end until GeeweeConfig::ACCEPTED_LOCALES.include?(l)
    c.locale = l

    c.save!
    puts '===> config is done!'
  end

  desc "Mega helper, to be run when installing geewee."
  task :first_run => :environment do
    if GeeweeConfig.already_configured?
      puts <<-EOF
puts 'Mhhh... it seems that you already configured geewee. Now by trying again
you tryied to either modify the configuration or to add a new user.

 - to change the geewee config, run `rake geewee:config'
 - to create a new author, run `rake geewee:new_author'
      EOF
      exit
    end

    puts <<-EOF
  =================================================
  === Welcome to the geewee configuration task! ===
  =================================================

Ok first, we'll setup the blog config. If you ever want to change something,
just run `rake geewee:config'. That's what we're going to do right now.

===> running `rake geewee:config'
EOF
    Rake::Task["geewee:config"].invoke

    puts <<-EOF

Ok, now we need to create an author. If you ever need to add a new one,
run `rake geewee:new_author' like we're doing now:

===> running `rake geewee:new_author'
EOF
  Rake::Task["geewee:new_author"].invoke

    puts <<-EOF

  ---------------------------------------------------------------------------
  Okay all is set! Now if you go to #{GeeweeConfig.entry.bloguri} you should
  see that a new author has been created, and a geewee client tutorial to help
  you writting your first post.

  Goodbye from geewee:first_run, have fun and thanks you for using geewee :D
EOF
  end
end
