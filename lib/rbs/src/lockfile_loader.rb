module Rbs
  module Src
    class LockfileLoader
      attr_reader :lockfile, :repository_prefix, :rbs_prefix

      def initialize(lockfile:, repository_prefix:, rbs_prefix:)
        @lockfile = lockfile
        @repository_prefix = repository_prefix
        @rbs_prefix = rbs_prefix
      end

      def each_gem()
        lockfile.gems.each_value do |library|
          case source = library[:source]
          when RBS::Collection::Sources::Git
            gem = Gem.new(
              name: library[:name],
              version: library[:version],
              repository_prefix: repository_prefix,
              repository_dir: Pathname(source.repo_dir),
              rbs_prefix: rbs_prefix
            )

            yield gem, source.remote, source.revision
          end
        end
      end
    end
  end
end
