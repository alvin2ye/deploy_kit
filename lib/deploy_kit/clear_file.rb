class ClearFile < DeployKit
  def final_filename
    File.join(backup_path, "*.gz")
  end

  def get_clear_days
     @fu_conf[:default_clear_days].to_i
  end

  def cmd
    "find %s -type f -mtime +%s -exec rm {} \\;"
  end

  def clear(path, days)
    full_cmd = cmd % [path || final_filename, days || get_clear_days]
    puts full_cmd if @verbose
    `#{full_cmd}`
  end
end
