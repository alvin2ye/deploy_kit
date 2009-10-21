class BackupLog < DeployKit
  def final_filename
    File.join(backup_path, "#{@fu_conf[:app_name]}_backup_log_#{timestamp}.tar.gz")
  end

  def cmd
    "tar -zcf %s log/*.log" % [final_filename]
  end

  def backup(store)
    puts cmd if @verbose
    `#{cmd}`
    S3storage.new.put(final_filename) if store == "s3"
  end
end
