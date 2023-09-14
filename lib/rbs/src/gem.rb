module Rbs
  module Src
    class Gem
      attr_reader :name, :version, :repository_prefix, :repository_dir, :rbs_prefix

      def initialize(name:, version:, repository_prefix:, repository_dir:, rbs_prefix:)
        @name = name
        @version = version
        @repository_prefix = repository_prefix
        @repository_dir = repository_dir
        @rbs_prefix = rbs_prefix
      end

      def repository_root
        repository_prefix + "#{name}-#{version}"
      end

      def repository_path
        repository_root.join(repository_dir, name, version)
      end

      def rbs_path
        rbs_prefix + "#{name}-#{version}"
      end

      def status(runner, commit:)
        unless runner.query!("git", "status", "-s", "-z", chdir: repository_root).split("\0").empty?
          return :dirty
        end

        if runner.query!("git", "rev-parse", "HEAD", chdir: repository_root).chomp != commit
          return :commit_mismatch
        end

        :ok
      end

      def checkout(runner, repository_url:, commit:)
        unless runner.query!("git", "status", "-s", "-z", chdir: repository_root).split("\0").empty?
          runner.puts "📣 Stashing uncommited changes... Restore the changes by: `git stash pop`"
          runner.execute!("git", "stash", "-u", "-m", "Stash by rbs-src on #{name}-#{version}", chdir: repository_root)
        end

        return if runner.query!("git", "rev-parse", "HEAD", chdir: repository_root).chomp == commit

        unless runner.query?("git", "cat-file", "-e", commit, chdir: repository_root)
          runner.puts "💾 Fetching from #{repository_url}..."
          runner.execute!("git", "remote", "set-url", "origin", repository_url, chdir: repository_root)
          runner.execute!("git", "fetch", "origin", chdir: repository_root)
        end

        runner.puts "💪 Checking out the commit #{commit}..."
        runner.execute!("git", "checkout", commit, chdir: repository_root)
      end

      def clone(runner, repository_url:, commit:)
        runner.puts "git clone..."
        runner.execute!("git", "clone", "--filter=blob:none", "--sparse", repository_url, repository_root.to_s)
        dirs = runner.query!("git", "ls-tree", "-d", "--name-only", "-z", "HEAD", chdir: repository_root).split("\0")
        dirs.delete(repository_dir.to_s)
        runner.execute!("git", "sparse-checkout", "set", *dirs, repository_dir.join(name).to_s, chdir: repository_root)
        if commit
          runner.puts "git checkout..."
          runner.execute!("git", "checkout", commit, chdir: repository_root)
        end
      end

      def link
        File.symlink(repository_path.relative_path_from(rbs_path.parent), rbs_path)
      end
    end
  end
end
