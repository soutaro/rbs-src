# rbs-src

rbs-src helps editing RBS files with `rbs collection`.

## The workflow

rbs-src helps editing RBS files by having git repositories for each gems and making symlinks to the repositories.

Assume you have a rbs collection setup loading activesupport-7.0 and sidekiq-6.2.
Running the `rbs-src setup` will make repositories and symlinks as the following:

```
- (Repository root)
  - Gemfile and other files
  - rbs_collection.yaml
  - rbs_collection.lock.yaml
  - tmp/rbs-src
    - activesupport-7.0               (a working copy of https://github.com/ruby/rbs_gem_collection.git)
      - gems/activesupport/7.0/*.rbs  (RBS files for activesupport-7.0)
    - sidekiq-6.0                     (another working copy of https://github.com/ruby/rbs_gem_collection.git)
      - gems/sidekiq/6.2/*.rbs        (RBS files for sidekiq-6.2)
  - sig/
    - **/*.rbs                        (RBS files for your Ruby program)
    - rbs-src/activesupport-7.0       (Symlink to /tmp/rbs-src/activesupport-7.0/gems/activesupport/7.0)
    - rbs-src/sidekiq-6.2             (Symlink to /tmp/rbs-src/sidekiq-6.2/gems/sidekiq/6.2)
```

The project structure allows the following workflow:

1. You can edit the RBS files of rbs collection directly through `sig/rbs-src/*/**.rbs`
2. Your changes are detected by Steep and used to type check your Ruby program code
3. You can push your changes to upstream through the git repositories under `tmp/rbs-src`

## Installation

    $ gem install rbs-src

## Usage

### rbs-src setup

Load gem dependencies from `rbs_collection.lock.yaml` and set up all repositories and symlinks.

    $ rbs-src setup

If the git repository content is edited, it runs `git stash` and `git reset --hard`.

It accepts `--output` option to write the dependencies to a file.

    $ rbs-src setup --output

You can load the dependencies to your type checkers from the file.

#### For Steep users

The recommended setup for Steep is the following:

```ruby
# Steepfile

target ... do
  # Existing config...

  # Assume we use `rbs-src setup --output` to generate `rbs_src.dep` file
  if (dep_path = Pathname("rbs_src.dep")).file?
    # Stop loading libraries through rbs-collection
    disable_collection()

    signature "sig/rbs-src/*/*.rbs"
    signature "sig/rbs-src/*/[^_]*/**/*.rbs"

    dep_path.readlines().each {|lib| library(lib.chomp) }
  end
end
```

In this setup, you can use Steep without using `rbs-src` until you run `rbs-src setup --output`.
Once you run `rbs-src setup --output`, it generates `rbs_src.dep` file and `Steepfile` loads the dependencies from the file.

```sh
# When you install your rbs_collection dependencies
$ rbs collection install && rbs-src setup --output

# When you update your rbs_collection dependencies
$ rbs collection update && rbs-src setup --output

# When you stop using rbs-src
$ rm -rf rbs_src.dep tmp/rbs-src sig/rbs-src
```

### rbs-src link

The command clones and set up a symlink of a ruby gem, not loaded from `rbs_collection.lock.yaml`.

    $ rbs-src link https://github.com/ruby/gem_rbs_collection.git active_emoji 0.0

This is typically useful for adding new gem to one of the collections.
The command will clone the git repository for `active_emoji-0.0` and make a symlink to non-existing directory.
You can add directories in the repository for `active_emoji-0.0` and start writing RBS files through the symlink.
Once you finished the edit, you can push the RBS files to upstream!

### rbs-src status

The command checks the status of all git repositories.

    $ rbs-src status
    [ok] activesupport tmp/rbs-src/activesupport-7.0
    [dirty] rainbow tmp/rbs-src/rainbow-3.0
    [commit_mismatch] ast tmp/rbs-src/ast-2.4

You may want to delete the repositories to reset, but use this command to ensure you don't have uncommitted changes.
(Note `rbs-src status` doesn't check if you pushed the commits to remotes.)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soutaro/rbs-src. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/soutaro/rbs-src/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rbs::Src project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/soutaro/rbs-src/blob/main/CODE_OF_CONDUCT.md).
