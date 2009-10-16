class LogMonitor < DeployKit
  def chekc_warning(will_sent = nil)
    mail_body = []

    cmd = "cat #{log_path} | grep \"200 OK\" | awk '{print $3 \" \" $0}' | sort -nr | head -n 10"
    puts cmd if @verbose
    lines = `#{cmd}`
    return if !need_send?(lines)

   if !will_sent.blank?
     send_mail(lines)
   else
     puts lines
   end
  end

  def allow_time
    @fu_conf[:allow_time_ms].to_i
  end

  def log_path
    File.join(RAILS_ROOT, "log", "production.log")
  end

  def need_send?(lines)
    result = nil
    time = lines.to_s.split(" ").first

    return false if time.blank?
    if is_ms?(time)
      if time.to_f > allow_time
        result = true
      end
    else
      if time.to_f > allow_time * 1000
        result = true
      end
    end

    result
  end

  def send_mail(lines)
    cmd = "echo \"#{lines}\" | mail #{@fu_conf[:to_mail]} -s \"#{@timestamp} #{@fu_conf[:app_name]} log \" -a \"From: #{@fu_conf[:from_mail]}\""
    puts cmd if @verbose
    `#{cmd}`
  end

  private
    def is_ms?(time)
      time.index("ms")
    end
end
