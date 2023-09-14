require "test_helper"

class Rbs::Src::GemTest < Minitest::Test

  def test_link
    Dir.mktmpdir do |dir|
      path = Pathname(dir)

      (path + "tmp/rbs-src").mkpath
      (path + "sig/rbs-src").mkpath

      Dir.chdir(dir) do
        Rbs::Src::Gem.new(
          name: "foo",
          version: "1.0",
          repository_prefix: path + "tmp/rbs-src",
          rbs_prefix: path + "sig/rbs-src",
          repository_dir: Pathname("gems")
        ).link()

        assert Pathname("sig/rbs-src/foo-1.0").symlink?

        Rbs::Src::Gem.new(
          name: "foo",
          version: "1.1",
          repository_prefix: path + "tmp/rbs-src",
          rbs_prefix: path + "sig/rbs-src",
          repository_dir: Pathname("gems")
        ).link()

        refute Pathname("sig/rbs-src/foo-1.0").exist?
        assert Pathname("sig/rbs-src/foo-1.1").symlink?

        Rbs::Src::Gem.new(
          name: "foo",
          version: "1.2",
          repository_prefix: path + "tmp/rbs-src",
          rbs_prefix: path + "sig/rbs-src",
          repository_dir: Pathname("gems")
        ).link()

        refute Pathname("sig/rbs-src/foo-1.0").exist?
        refute Pathname("sig/rbs-src/foo-1.1").exist?
        assert Pathname("sig/rbs-src/foo-1.2").symlink?
      end
    end
  end
end
