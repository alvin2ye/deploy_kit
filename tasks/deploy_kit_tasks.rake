require 'fileutils'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'deploy_kit'

namespace :deploy do
  desc "rake deploy:backup_mysql or rake deploy:backup_mysql STORE=s3"
  task :backup_mysql do
    BackupMysql.new.backup(ENV["STORE"])
  end

  desc "rake deploy:backup_log or rake deploy:backup_log STORE=s3"
  task :backup_log do
    BackupLog.new.backup(ENV["STORE"])
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
