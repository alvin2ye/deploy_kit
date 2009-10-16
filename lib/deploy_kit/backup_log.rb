class BackupLog < DeployKit
  def final_filename
    File.join(backup_path, "backup_log_#{timestamp}.tar.gz")
  end

  def cmd
    "tar -zcf %s log/*.log" % [final_filename]
  end

  def backup
    puts cmd if @verbose
    `#{cmd}`
  end
end
