module Rbs
  module Src
    class Link
      attr_reader :repo_url, :base_path, :repository_prefix, :rbs_prefix, :gem_name, :gem_version, :force, :stdout

      def initialize(stdout:, repo_url:, base_path:, repository_prefix:, rbs_prefix:, gem_name:, gem_version:, force:)
        @stdout = stdout
        @repo_url = repo_url
        @base_path = base_path
        @repository_prefix = repository_prefix
        @rbs_prefix = rbs_prefix
        @gem_name = gem_name
        @gem_version = gem_version
        @force = force
      end

      def rbs_path
        rbs_prefix + "#{gem_name}-#{gem_version}"
      end

      def repository_path
        repository_prefix + "#{gem_name}-#{gem_version}"
      end

      def clean
        rbs_path.delete
        repository_path.rmtree
      end

      def repository_sig_path
        repository_path.join("gems", gem_name, gem_version)
      end

      def run
        repository_prefix.mkpath
        rbs_prefix.mkpath

        sh!(*clone_command)

        unless repository_sig_path.directory?
          unless force
            stdout.puts "Cannot find a directory for #{gem_name}-#{gem_version} in #{repository_path}"
            return
          end
        end

        File.symlink(repository_sig_path.relative_path_from(rbs_path.parent), rbs_path)
      end

      def sh!(*args, chdir: base_path)
        pid = spawn(*args, chdir: chdir.to_s)
        _, status = Process.waitpid2(pid)

        unless status.success?
          raise "Failed to execute a command in `#{chdir}`: #{args.inspect} => #{status.inspect}"
        end
      end

      def clone_command
        [
          "git",
          "clone",
          "--filter=blob:none",
          repo_url,
          repository_path.to_s
        ]
      end
    end
  end
end
