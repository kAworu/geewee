namespace :geewee do
  def ask question
    print question
    STDIN.gets.chomp
  end

  desc "Mega helper, to be run when installing geewee."
  task :setup => :environment do
    config = Hash.new
    puts "==================================================="
    puts "=== Welcome to the geewee configuration script! ==="
    puts "==================================================="
    puts

    I18n.locale = :en

    puts "first we're gonna setup some info about you. We'll create an admin author"
    author = nil
    until author and author.valid?
      if author.nil?
        author = Author.new
      else
        puts "- #{author.errors.map { |err| err.join(' ') }.join("\n- ")}"
        puts "Ok, don't worry, try again :)"
      end
        author.name = ask("what's your author name? ")
        author.email  = ask("what's your email? ")
    end
    author.save!
    config['geewee_api_key'] = author.single_access_token
    puts "Ok #{author.name}! You're account has been created."

    while config['base_url'].blank?
      config['base_url'] = \
        ask("now, what is your geewee url? (for example, mine is http://blog.kaworu.ch): ")
    end
    # fix URL to require http://
    config['base_url'] = "http://#{config['base_url']}" unless config['base_url'] =~ %r{^http://}

    editor = ask("finally, what is your favourite editor? (if blank, $EDITOR will be used): ")
    config['editor'] = editor unless editor.blank?

    clientpath = "tmp/geewee_#{author.name}"
    File.open(clientpath, "w") do |wfd|
      catch(:eos) do
        File.open('client/geewee') do |rfd|
          rfd.each_line do |line|
            wfd << line
            throw :eos if line.chomp == '__END__'
          end
        end
      end
      wfd << config.to_yaml
    end
    File.chmod(0700, clientpath)
    puts "Nice! geewee setup is now complete, your client script is here: #{clientpath}"
    puts "Have fun and thanks you for using geewee :D"
  end
end
