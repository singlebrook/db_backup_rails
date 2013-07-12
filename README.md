# DbBackupRails

This simple gem creates database dump files on the local filesystem. The
authors use it to enable consistent nightly database backups on cloud servers.

## Installation

Add this line to your application's Gemfile:

    gem 'db_backup_rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install db_backup_rails

If you are using Rails 2.3, add the following to your Rakefile:

    require 'db_backup_rails/tasks'

## Usage

This gem provides `backup:db` and `backup:db:prune` rake tasks.

    bundle exec rake backup:db
    bundle exec rake backup:db:prune

### Custom Directory

This defaults to using a directory at `[Rails.root]/../shared/backup`, which
works well with Capistrano's standard directory structure. You can override it
by setting `BACKUP_DIR`. If `BACKUP_DIR` is relative, it will be relative to
`Rails.root`. E.g.

    BACKUP_DIR=tmp/backup bundle exec rake backup:db

will back up to `[Rails.root]/tmp/backup`.

`BACKUP_DIR` applies to all provided tasks.

### Setting the number of versions to keep when pruning

`backup:db:prune` keeps 7 versions by default. You can override this with
`NUMBER_TO_KEEP`, e.g.

    NUMBER_TO_KEEP=30 bundle exec rake backup:db:prune

### Setting the Rails environment

As with most rake tasks, you can specify RAILS_ENV if you want to operate on an
environment other than development.

## Limitations

* Currently only works with MySQL. Postgres support should be coming soon.
* Will only back up local databases, not those on another machine.
* Only works on Unix-y systems

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
