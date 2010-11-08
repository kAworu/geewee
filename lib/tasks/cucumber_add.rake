task :stats => "cucumber:statsetup"

namespace :cucumber do
  # Setup cucumber for stats
  task :statsetup do
    require 'code_statistics'
    ::STATS_DIRECTORIES << %w(Cucumber\ features features) if File.exist?('features')
    ::CodeStatistics::TEST_TYPES << "Cucumber features" if File.exist?('features')
  end
end
