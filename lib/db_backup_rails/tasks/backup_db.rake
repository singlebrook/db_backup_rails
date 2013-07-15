# Simple database backup rake task
# Supports mysql and postgres
# Env vars:
#   BACKUP_DIR - where to store files. Relative to Rails app root. Defaults to '../shared/backup',
#                which works nicely with Capistrano's default file structure.
#   NUM_TO_KEEP - how many backup files to keep. Defaults to 7.
#   RAILS_ENV - which database to back up. Defaults to development like all Rake tasks.

namespace :backup do
  desc "Backup database"
  task :db => [:environment] do
    FileUtils.mkdir_p backup_dir

    adapter = settings['adapter']
    host = settings['host'] || '127.0.0.1'
    port = settings['port']
    database = settings['database']
    user = settings['user']
    password = settings['password']

    # Run the appropriate backup utility
    case adapter
    when 'mysql'
      port ||= '3306'
      password_arg = password.present? ? "-p#{password}" : ''
      system "/usr/bin/env mysqldump -h #{host} -P #{port} -u #{user} #{password_arg} #{database} > #{output_file}"
    when 'postgresql'
      port ||= '5432'

      # pg_dump doesn't take a password arg, so we have to write the password to the ~/.pgpass file.
      pgpass_file = ENV['HOME']+'/.pgpass'
      pgpass_content = "#{host}:#{port}:#{database}:#{user}:#{password}"
      File.open(pgpass_file, 'a+') do |pgpass|
        pgpass.write(pgpass_content) unless pgpass.grep(pgpass_content).present?
      end

      # Ensure that .pgpass has the correct mode (only really needed if we just)
      # created it.
      # Ruby 1.8/1.9 compatibility
      file_util_class = File.respond_to?(:chmod) ? File : FileUtils
      file_util_class.chmod(0600, pgpass_file)

      system "/usr/bin/env pg_dump -Fc -U #{user} --no-password #{database} > #{output_file}"
    else
      raise RuntimeError, "I don't know how to back up #{settings['adapter']} databases!"
    end
    system "/usr/bin/env gzip -f #{output_file}"
  end

  namespace :db do
    desc "Prune database backups"
    task :prune => [:environment] do
      files = Dir.glob("#{output_file_prefix}-*")

      r_index = (-1 * num_to_keep) - 1

      if files.length > num_to_keep
        files[0..r_index].each do |file|
          FileUtils.rm file
        end
      end
    end
  end

  def backup_dir
    relative_dir = ENV['BACKUP_DIR'] || '../shared/backup'
    File.expand_path(relative_dir, Rails.root)
  end

  def output_file
    File.expand_path("#{output_file_prefix}-#{Time.now.strftime('%Y%m%d')}.dump", Rails.root)
  end

  def output_file_prefix
    "#{backup_dir}/#{settings['database']}"
  end

  def num_to_keep
    ENV['NUM_TO_KEEP'].to_i || 7
  end

  def settings
    @settings ||= YAML.load(File.read(Rails.root.join("config", "database.yml")))[Rails.env]
  end
end