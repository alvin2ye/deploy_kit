require 'fileutils'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'deploy_kit'

namespace :deploy do
  desc "backup_mysql"
  task :backup_mysql do
    puts "backup mysql"
    BackupMysql.new.backup
  end

  desc "backup_log"
  task :backup_log do
    puts "backup log"
    BackupLog.new.backup
  end
end
