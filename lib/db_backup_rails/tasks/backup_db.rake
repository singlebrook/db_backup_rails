# Simple database backup rake task
# Supports mysql
# Env vars:
#   BACKUP_DIR - where to store files. Relative to Rails app root. Defaults to '../shared/backup',
#                which works nicely with Capistrano's default file structure.
#   NUM_TO_KEEP - how many backup files to keep. Defaults to 7.
#   RAILS_ENV - which database to back up. Defaults to development like all Rake tasks.

namespace :backup do
  desc "Backup database"
  task :db => [:environment] do
    password_arg = settings['password'].present? ? "-p#{settings['password']}" : ''

    FileUtils.mkdir_p backup_dir

    # Run the appropriate backup utility
    case settings['adapter']
    when 'mysql'
      system "/usr/bin/env mysqldump -u #{settings['user']} #{password_arg} #{settings['database']} > #{output_file}"
    # when 'postgresl'
    #   system "/usr/bin/env pgdump -Fc -u #{settings['user']} #{password_arg} #{settings['database']} > #{output_file}"
    else
      raise RuntimeError, "I don't know how to back up #{settings['adapter']} databases!"
    end
    system "/usr/bin/env gzip -f #{output_file}"
  end

  namespace :db do
    desc "Prune database backups"
    task :prune => [:environment] do
      files = Dir.glob("#{backup_dir}/#{settings['database']}-*")

      r_index = (-1 * num_to_keep) - 1

      if files.length > num_to_keep
        files[0..r_index].each do |file|
          FileUtils.rm file
        end
      end
    end
  end

  def app_root
    root = RAILS_ROOT || Rails.root
    raise RuntimeError, 'Could not determine Rails root' unless root
    root
  end

  def backup_dir
    relative_dir = ENV['BACKUP_DIR'] || '../shared/backup'
    File.expand_path(relative_dir, app_root)
  end

  def output_file
    File.expand_path("#{backup_dir}/#{settings['database']}-#{Time.now.strftime('%Y%m%d')}.dump", app_root)
  end

  def num_to_keep
    ENV['NUM_TO_KEEP'].to_i || 7
  end

  def rails_env
    ENV['RAILS_ENV'] || 'development'
  end

  def settings
    @settings ||= YAML.load(File.read(File.join(app_root, "config", "database.yml")))[rails_env]
  end
end