class BackupMysql < DeployKit
  def final_filename
    @final_filename ||= File.join(backup_path, "#{@fu_conf[:app_name]}_backup_mysql_#{timestamp}.gz")
  end

  def cmd
    """mysqldump -u\"#{@db_conf[:username]}\" -p\"#{@db_conf[:password]}\" \
    --default-character-set=utf8 --opt --extended-insert=false \
    --triggers -R --hex-blob --single-transaction #{options} #{@db_conf[:database]} | gzip \
    > #{final_filename}
    """
  end

  def backup(store)
    puts cmd if @verbose
    `#{cmd}`
    S3storage.new.put(final_filename) if store == "s3"
  end

  def options
    options = []

    if !@db_conf[:socket].blank?
      options << "--socket=#{@db_conf[:socket]}"
    end

    options.join(" ")
  end
end
