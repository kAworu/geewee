begin
  require 'cucumber/rake/task'

  task :stats => "cucumber:statsetup"

  namespace :cucumber do
    # Setup cucumber for stats
    task :statsetup do
      require 'code_statistics'
      ::STATS_DIRECTORIES << %w(Cucumber\ features features) if File.exist?('features')
      ::CodeStatistics::TEST_TYPES << "Cucumber features" if File.exist?('features')
    end

    Cucumber::Rake::Task.new(:rcov) do |t|
      t.rcov = true
      t.rcov_opts = %w{--rails --exclude osx\/objc,gems\/,spec\/}
      t.rcov_opts << %[-o "features_rcov"]
    end
  end
rescue LoadError
  # ok nevermind
end
