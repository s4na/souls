module Scaffold
  def self.scaffold_steepfile
    <<~STEEPFILE
            target :app do
        signature "sig"
        repo_path "vendor/rbs/gem_rbs_collection/gems"
        library "pathname"
        library "logger"
        library "mutex_m"
        library "date"
        library "monitor"
        library "singleton"
        library "tsort"
        library "time"
        library "erb"

        library "rack"

        library "activesupport"
        library "actionpack"
        library "activejob"
        library "activemodel"
        library "actionview"
        library "activerecord"
        library "railties"
        library "uri"
        library "fileutils"
        library "graphql"

        check "apps/api/app"
        check "apps/api/db/seeds.rb"
        check "apps/api/constants"
        check "apps/api/app.rb"
      end
    STEEPFILE
  end
end
