require "optparse"

module Rbs
  module Src
    class CLI
      def self.start(argv)
        command = argv.shift

        case command
        when "link"
          repository_prefix = Pathname("tmp/rbs-src")
          rbs_prefix = Pathname("sig/gems")
          force = false

          OptionParser.new do |opts|
            opts.on("--repo-prefix=PREFIX") { repository_prefix = Pathname(_1) }
            opts.on("--rbs-prefix=PREFIX") { rbs_prefix = Pathname(_1) }
            opts.on("--force") { force = true }
          end.parse!(argv)

          repo_url = argv.shift or raise
          gem_name = argv.shift or raise
          gem_version = argv.shift or raise

          link = Link.new(
            stdout: STDOUT,
            base_path: Pathname.pwd,
            repo_url: repo_url,
            repository_prefix: repository_prefix,
            rbs_prefix: rbs_prefix,
            gem_name: gem_name,
            gem_version: gem_version,
            force: force,
          )
          link.run
          0
        when "open"

          RBS::Collection::Config::Lockfile
          1
        when "setup"
          1
        else
          puts "Unknown command: #{command}"
          1
        end
      end
    end
  end
end
