require "test_helper"

require "rbs/src/cli"

class Rbs::Src::CommandTest < Minitest::Test
  def stdout
    @stdout ||= StringIO.new
  end

  def test_link__existing_gem
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Rbs::Src::CLI.start(
          [
            "link",
            "https://github.com/ruby/gem_rbs_collection.git",
            "activesupport",
            "7.0"
          ],
          stdout: stdout
        )

        assert_predicate Pathname.pwd.join("sig/rbs-src"), :directory?
        assert_predicate Pathname.pwd.join("sig/rbs-src/activesupport-7.0"), :symlink?
        assert_predicate Pathname.pwd.join("sig/rbs-src/activesupport-7.0"), :directory?
        assert_equal Pathname("../../tmp/rbs-src/activesupport-7.0/gems/activesupport/7.0"), Pathname.pwd.join("sig/rbs-src/activesupport-7.0").readlink

        assert_predicate Pathname.pwd.join("tmp/rbs-src/activesupport-7.0"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/activesupport-7.0/gems/activesupport/7.0"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/activesupport-7.0/bin"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/activesupport-7.0/generators"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/activesupport-7.0/Gemfile"), :file?
      end
    end
  end

  def test_link__new_gem
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        Rbs::Src::CLI.start(
          [
            "link",
            "https://github.com/ruby/gem_rbs_collection.git",
            "__no_such_gem__",
            "1.2"
          ],
          stdout: stdout
        )

        assert_predicate Pathname.pwd.join("sig/rbs-src"), :directory?
        assert_predicate Pathname.pwd.join("sig/rbs-src/__no_such_gem__-1.2"), :symlink?
        refute_predicate Pathname.pwd.join("sig/rbs-src/__no_such_gem__-1.2"), :directory?
        assert_equal Pathname("../../tmp/rbs-src/__no_such_gem__-1.2/gems/__no_such_gem__/1.2"), Pathname.pwd.join("sig/rbs-src/__no_such_gem__-1.2").readlink

        assert_predicate Pathname.pwd.join("tmp/rbs-src/__no_such_gem__-1.2"), :directory?
        refute_predicate Pathname.pwd.join("tmp/rbs-src/__no_such_gem__-1.2/gems/__no_such_gem__/1.2"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/__no_such_gem__-1.2/bin"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/__no_such_gem__-1.2/generators"), :directory?
        assert_predicate Pathname.pwd.join("tmp/rbs-src/__no_such_gem__-1.2/Gemfile"), :file?
      end
    end
  end

  def test_setup
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        (Pathname.pwd + "rbs_collection.yaml").write(<<~YAML)
          sources:
            - type: git
              name: ruby/gem_rbs_collection
              remote: https://github.com/ruby/gem_rbs_collection.git
              revision: main
              repo_dir: gems

          path: .gem_rbs_collection

          gems:
            - name: ast
            - name: rainbow
        YAML
        (Pathname.pwd + "rbs_collection.lock.yaml").write(<<~YAML)
          ---
          sources:
          - type: git
            name: ruby/gem_rbs_collection
            revision: 9330d49993d18362cce9190b9596f03d1f4915f8
            remote: https://github.com/ruby/gem_rbs_collection.git
            repo_dir: gems
          path: ".gem_rbs_collection"
          gems:
          - name: abbrev
            version: '0'
            source:
              type: stdlib
          - name: ast
            version: '2.4'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: json
            version: '0'
            source:
              type: stdlib
          - name: logger
            version: '0'
            source:
              type: stdlib
          - name: minitest
            version: '0'
            source:
              type: stdlib
          - name: monitor
            version: '0'
            source:
              type: stdlib
          - name: mutex_m
            version: '0'
            source:
              type: stdlib
          - name: optparse
            version: '0'
            source:
              type: stdlib
          - name: pathname
            version: '0'
            source:
              type: stdlib
          - name: rainbow
            version: '3.0'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: rbs
            version: 3.1.2
            source:
              type: rubygems
          - name: rdoc
            version: '0'
            source:
              type: stdlib
          - name: tsort
            version: '0'
            source:
              type: stdlib
          gemfile_lock_path: "Gemfile.lock"
        YAML

        Rbs::Src::CLI.start(%w(setup), stdout: stdout)

        assert_predicate Pathname.pwd.join("sig/rbs-src/ast-2.4"), :directory?
        assert_equal Pathname("../../tmp/rbs-src/ast-2.4/gems/ast/2.4"), Pathname.pwd.join("sig/rbs-src/ast-2.4").readlink
        assert_predicate Pathname("tmp/rbs-src/ast-2.4/gems/ast/2.4"), :directory?

        assert_predicate Pathname.pwd.join("sig/rbs-src/rainbow-3.0"), :directory?
        assert_equal Pathname("../../tmp/rbs-src/rainbow-3.0/gems/rainbow/3.0"), Pathname.pwd.join("sig/rbs-src/rainbow-3.0").readlink
        assert_predicate Pathname("tmp/rbs-src/rainbow-3.0/gems/rainbow/3.0"), :directory?
      end
    end
  end

  def test_setup__checkout
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        (Pathname.pwd + "rbs_collection.yaml").write(<<~YAML)
          sources:
            - type: git
              name: ruby/gem_rbs_collection
              remote: https://github.com/ruby/gem_rbs_collection.git
              revision: main
              repo_dir: gems

          path: .gem_rbs_collection

          gems:
            - name: ast
            - name: rainbow
        YAML
        (Pathname.pwd + "rbs_collection.lock.yaml").write(<<~YAML)
          ---
          sources:
          - type: git
            name: ruby/gem_rbs_collection
            revision: 9330d49993d18362cce9190b9596f03d1f4915f8
            remote: https://github.com/ruby/gem_rbs_collection.git
            repo_dir: gems
          path: ".gem_rbs_collection"
          gems:
          - name: abbrev
            version: '0'
            source:
              type: stdlib
          - name: ast
            version: '2.4'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: json
            version: '0'
            source:
              type: stdlib
          - name: logger
            version: '0'
            source:
              type: stdlib
          - name: minitest
            version: '0'
            source:
              type: stdlib
          - name: monitor
            version: '0'
            source:
              type: stdlib
          - name: mutex_m
            version: '0'
            source:
              type: stdlib
          - name: optparse
            version: '0'
            source:
              type: stdlib
          - name: pathname
            version: '0'
            source:
              type: stdlib
          - name: rainbow
            version: '3.0'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: rbs
            version: 3.1.2
            source:
              type: rubygems
          - name: rdoc
            version: '0'
            source:
              type: stdlib
          - name: tsort
            version: '0'
            source:
              type: stdlib
          gemfile_lock_path: "Gemfile.lock"
        YAML

        Rbs::Src::CLI.start(%w(setup), stdout: stdout)

        stdout.string = String.new

        Pathname.pwd.join("sig/rbs-src/ast-2.4/foobar.rbs").write("Foo: Integer")
        Open3.capture2e("git", "reset", "--hard", "306d1ae", chdir: Pathname.pwd.join("tmp/rbs-src/rainbow-3.0"))

        Rbs::Src::CLI.start(%w(setup), stdout: stdout)

        out, _ = Open3.capture2e("git", "status", "-s", chdir: Pathname.pwd.join("tmp/rbs-src/ast-2.4"))
        assert_empty out

        sha, _ = Open3.capture2e("git", "rev-parse", "HEAD", chdir: Pathname.pwd.join("tmp/rbs-src/rainbow-3.0"))
        sha.chomp!
        assert_equal "9330d49993d18362cce9190b9596f03d1f4915f8", sha
      end
    end
  end

  def test_setup__output
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        (Pathname.pwd + "rbs_collection.yaml").write(<<~YAML)
          sources:
            - type: git
              name: ruby/gem_rbs_collection
              remote: https://github.com/ruby/gem_rbs_collection.git
              revision: main
              repo_dir: gems

          path: .gem_rbs_collection

          gems:
            - name: ast
            - name: rainbow
        YAML
        (Pathname.pwd + "rbs_collection.lock.yaml").write(<<~YAML)
          ---
          sources:
          - type: git
            name: ruby/gem_rbs_collection
            revision: 9330d49993d18362cce9190b9596f03d1f4915f8
            remote: https://github.com/ruby/gem_rbs_collection.git
            repo_dir: gems
          path: ".gem_rbs_collection"
          gems:
          - name: abbrev
            version: '0'
            source:
              type: stdlib
          - name: ast
            version: '2.4'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: json
            version: '0'
            source:
              type: stdlib
          - name: logger
            version: '0'
            source:
              type: stdlib
          - name: minitest
            version: '0'
            source:
              type: stdlib
          - name: monitor
            version: '0'
            source:
              type: stdlib
          - name: mutex_m
            version: '0'
            source:
              type: stdlib
          - name: optparse
            version: '0'
            source:
              type: stdlib
          - name: pathname
            version: '0'
            source:
              type: stdlib
          - name: rainbow
            version: '3.0'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: rbs
            version: 3.1.2
            source:
              type: rubygems
          - name: rdoc
            version: '0'
            source:
              type: stdlib
          - name: tsort
            version: '0'
            source:
              type: stdlib
          gemfile_lock_path: "Gemfile.lock"
        YAML

        Rbs::Src::CLI.start(%w(setup -o), stdout: stdout)

        dep_path = Pathname("rbs_src.dep")
        assert_predicate dep_path, :file?
        assert_equal %w(abbrev json logger minitest monitor mutex_m optparse pathname rbs rdoc tsort), dep_path.readlines(chomp: true)
      end
    end
  end

  def test_status
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        (Pathname.pwd + "rbs_collection.yaml").write(<<~YAML)
          sources:
            - type: git
              name: ruby/gem_rbs_collection
              remote: https://github.com/ruby/gem_rbs_collection.git
              revision: main
              repo_dir: gems

          path: .gem_rbs_collection

          gems:
            - name: ast
            - name: rainbow
        YAML
        (Pathname.pwd + "rbs_collection.lock.yaml").write(<<~YAML)
          ---
          sources:
          - type: git
            name: ruby/gem_rbs_collection
            revision: 9330d49993d18362cce9190b9596f03d1f4915f8
            remote: https://github.com/ruby/gem_rbs_collection.git
            repo_dir: gems
          path: ".gem_rbs_collection"
          gems:
          - name: abbrev
            version: '0'
            source:
              type: stdlib
          - name: ast
            version: '2.4'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: json
            version: '0'
            source:
              type: stdlib
          - name: logger
            version: '0'
            source:
              type: stdlib
          - name: minitest
            version: '0'
            source:
              type: stdlib
          - name: monitor
            version: '0'
            source:
              type: stdlib
          - name: mutex_m
            version: '0'
            source:
              type: stdlib
          - name: optparse
            version: '0'
            source:
              type: stdlib
          - name: pathname
            version: '0'
            source:
              type: stdlib
          - name: rainbow
            version: '3.0'
            source:
              type: git
              name: ruby/gem_rbs_collection
              revision: 9330d49993d18362cce9190b9596f03d1f4915f8
              remote: https://github.com/ruby/gem_rbs_collection.git
              repo_dir: gems
          - name: rbs
            version: 3.1.2
            source:
              type: rubygems
          - name: rdoc
            version: '0'
            source:
              type: stdlib
          - name: tsort
            version: '0'
            source:
              type: stdlib
          gemfile_lock_path: "Gemfile.lock"
        YAML

        Rbs::Src::CLI.start(%w(setup), stdout: stdout)

        Pathname.pwd.join("sig/rbs-src/ast-2.4/foobar.rbs").write("Foo: Integer")
        Open3.capture2e("git", "reset", "--hard", "306d1ae", chdir: Pathname.pwd.join("tmp/rbs-src/rainbow-3.0"))

        stdout.string = String.new

        Rbs::Src::CLI.start(%w(status), stdout: stdout)

        assert_equal <<~MESSAGE, stdout.string
          [dirty] ast tmp/rbs-src/ast-2.4
          [commit_mismatch] rainbow tmp/rbs-src/rainbow-3.0
        MESSAGE
      end
    end
  end
end

