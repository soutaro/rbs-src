require "optparse"

module Rbs
  module Src
    class CLI
      def self.start(argv, stdout: STDOUT)
        command = argv.shift

        case command
        when "link"
          repository_prefix = Pathname("tmp/rbs-src")
          rbs_prefix = Pathname("sig/rbs-src")
          repository_dir = Pathname("gems")

          OptionParser.new do |opts|
            opts.on("--repo-prefix=PREFIX", "The location to put repository in (default: #{repository_prefix})") { repository_prefix = Pathname(_1) }
            opts.on("--repo-dir=DIR", "The collection repository dir name (default: #{repository_dir})") { repository_dir = Pathname(_1) }
            opts.on("--rbs-prefix=PREFIX", "The location to put symlinks in (default: #{rbs_prefix})") { rbs_prefix = Pathname(_1) }

            opts.banner = <<~BANNER
              Usage: rbs-src link [options] repo_url gem_name gem_version

              Clone the repository and set up a symlink.

              Example:
                  $ rbs-src link https://github.com/ruby/gem_rbs_collection.git activerecord 7.0
                  $ rbs-src link https://github.com/ruby/gem_rbs_collection.git parseg 1.0

              Options:
            BANNER
          end.parse!(argv)

          repository_prefix.mkpath
          rbs_prefix.mkpath

          repo_url = argv.shift or raise
          gem_name = argv.shift or raise
          gem_version = argv.shift or raise

          gem = Gem.new(
            name: gem_name,
            version: gem_version,
            repository_prefix: repository_prefix,
            repository_dir: repository_dir,
            rbs_prefix: rbs_prefix
          )

          runner = CommandRunner.new(stdout: stdout)

          runner.push "Setting up #{gem.name}-#{gem.version}" do
            runner.push "Cloning git repository into #{gem.repository_root}" do
              if gem.repository_root.directory?
                runner.puts "Skipping already exist"
              else
                gem.clone(runner, repository_url: repo_url, commit: nil)
              end
            end

            runner.push "Linking to #{gem.rbs_path}" do
              unless gem.rbs_path.exist?
                runner.puts "File.symlink..."
                gem.link()
              else
                runner.puts "Skipping already exist"
              end
            end
          end

          0
        when "setup"
          rbs_collection_lock_path = RBS::Collection::Config.to_lockfile_path(RBS::Collection::Config::PATH)
          repository_prefix = Pathname("tmp/rbs-src")
          rbs_prefix = Pathname("sig/rbs-src")

          OptionParser.new do |opts|
            opts.on("--rbs-collection-lock=PATH", "The path to rbs_collection.lock.yaml (default: #{rbs_collection_lock_path})") { rbs_collection_lock_path = Pathname(_1) }
            opts.on("--repo-prefix=PREFIX", "The location to put repository in (default: #{repository_prefix})") { repository_prefix = Pathname(_1) }
            opts.on("--rbs-prefix=PREFIX", "The location to put symlinks in (default: #{rbs_prefix})") { rbs_prefix = Pathname(_1) }

            opts.banner = <<~BANNER
              Usage: rbs-src setup [options]

              Set up git repositories and symlinks in rbs_collection.yaml.

              Example:
                  $ rbs-src setup

              Options:
            BANNER
          end.parse!(argv)

          rbs_prefix.mkpath
          rbs_prefix.mkpath

          lockfile = RBS::Collection::Config::Lockfile.from_lockfile(
            lockfile_path: rbs_collection_lock_path,
            data: YAML.safe_load(rbs_collection_lock_path.read)
          )

          loader = LockfileLoader.new(
            lockfile: lockfile,
            repository_prefix: repository_prefix,
            rbs_prefix: rbs_prefix
          )

          runner = CommandRunner.new(stdout: stdout)

          loader.each_gem do |gem, repo, commit|
            runner.push "Setting up #{gem.name}-#{gem.version}" do
              if gem.repository_root.directory?
                runner.push "Checking out commit in #{gem.repository_root}" do
                  gem.checkout(runner, repository_url: repo, commit: commit)
              end
              else
                runner.push "Cloning git repository into #{gem.repository_root}" do
                  gem.clone(runner, repository_url: repo, commit: commit)
                end
              end

              runner.push "Linking to #{gem.rbs_path}" do
                unless gem.rbs_path.exist?
                  runner.puts "File.symlink..."
                  gem.link()
                else
                  runner.puts "Skipping already exist"
                end
              end
            end
          end

          other_libs = [] #: Array[[String, String]]
          lockfile.gems.each_value do |gem|
            case source = gem[:source]
            when RBS::Collection::Sources::Git
              # skip
            else
              other_libs << [gem[:name], gem[:version]]
            end
          end

          other_libs.sort_by! { _1[0] }

          unless other_libs.empty?
            runner.push "You have to load other libraries without rbs-collection:" do
              if has_gem?("steep")
                runner.puts "Add the following lines in your Steepfile:"

                other_libs.each do |name, version|
                  runner.puts "  library('#{name}')"
                end
              else
                other_libs.each do |name, version|
                  runner.puts "-r #{name} \\"
                end
              end
            end
          end

          0
        else
          puts "Unknown command: #{command}"
          puts
          puts "  known commands: setup, status, link"
          1
        end
      end

      def self.has_gem?(name)
        ::Gem::Specification.find_by_name(name)
        true
      rescue
        false
      end
    end
  end
end
