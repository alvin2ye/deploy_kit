class BackupMysql < DeployKit
  def final_filename
    File.join(backup_path, "backup_mysql_#{timestamp}.gz")
  end

  def cmd
    """mysqldump -u#{@db_conf[:username]} -p#{@db_conf[:password]} \
    --default-character-set=utf8 --opt --extended-insert=false \
    --triggers -R --hex-blob --single-transaction #{@db_conf[:database]} | gzip \
    > #{final_filename}
    """
  end

  def backup
    puts cmd if @verbose
    `#{cmd}`
  end
end
