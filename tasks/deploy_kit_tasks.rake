require 'fileutils'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'deploy_kit'

namespace :deploy do
  desc "rake deploy:setup copy amazon_s3.yml.sample, deploy_kit.yml.sample"
  task :setup do
    ['amazon_s3.yml.sample', 'deploy_kit.yml.sample'].each do |file|
      srcfile = File.join(File.dirname(__FILE__), '..', 'config', file)
      destfile = File.join(RAILS_ROOT, 'config', file)

      if File.exist?(destfile)
        puts "\nTarget file: #{destfile}\n ... already exists.  Aborting.\n\n"
      else
        FileUtils.cp(srcfile, destfile)
        puts "cp config/#{file} config/#{file.gsub('.sample', '')}"
      end
    end
  end

  desc "rake deploy:backup_mysql or rake deploy:backup_mysql STORE=s3"
  task :backup_mysql do
    BackupMysql.new.backup(ENV["STORE"])
  end

  desc "rake deploy:backup_log or rake deploy:backup_log STORE=s3"
  task :backup_log do
    BackupLog.new.backup(ENV["STORE"])
  end

  desc "Clear files in date, rake deploy:clear or rake deploy:clear BACKUP_PATH=/tmp/*.log DAYS=10 defaut BACKUP_PATH: RAILS_ROOT/config/deploy_kit.yml key dump_base_path or 'RAILS_ROOT/backup/*.gz' DAYS: config key default_clear_days"
  task :clear do
    ClearFile.new.clear(ENV["BACKUP_PATH"], ENV["DAYS"])
  end
end

namespace :s3 do
  desc "list"
  task :list do
    S3storage.new.list
  end

  desc "store file use ENV like: rake s3:put FILE=/tmp/xx.tar.gz"
  task :put do
    S3storage.new.put(ENV["FILE"])
  end

  desc "download file like: rake s3:get KEY=xx.tar.gz"
  task :get do
    puts "..." # TODO impl
  end
end

namespace :monitor do
  desc "or rake monitor:slow_log SEND_MAIL=true"
  task :slow_log do
    LogMonitor.new.check_warning(ENV["SEND_MAIL"])
  end
end
