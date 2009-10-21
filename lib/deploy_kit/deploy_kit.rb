class DeployKitConfigError < Exception; end

class DeployKit
  def initialize
    db_conf = YAML.load_file(File.join(RAILS_ROOT, 'config', 'database.yml'))
    @db_conf = db_conf[RAILS_ENV].symbolize_keys

    raw_config = File.read(File.join(RAILS_ROOT, 'config', 'deploy_kit.yml'))
    erb_config = ERB.new(raw_config).result
    fu_conf    = YAML.load(erb_config)
    @fu_conf   = fu_conf[RAILS_ENV].symbolize_keys

    @s3_conf = YAML.load_file(File.join(RAILS_ROOT, 'config', 'amazon_s3.yml'))[RAILS_ENV].symbolize_keys
    @fu_conf[:s3_bucket] ||= @s3_conf[:bucket_name]
    @fu_conf[:aws_access_key_id] ||= @s3_conf[:access_key_id]
    @fu_conf[:aws_secret_access_key] ||= @s3_conf[:secret_access_key]

    @fu_conf[:mysqldump_options] ||= '--complete-insert --skip-extended-insert'
    @verbose = !@fu_conf[:verbose].nil?
    @fu_conf[:keep_files] ||= 5
    check_conf
    create_dirs
  end

  def check_conf
    @fu_conf[:s3_bucket] = ENV['s3_bucket'] unless ENV['s3_bucket'].blank?
    if @fu_conf[:app_name] == 'replace_me'
      raise DeployKitConfigError, 'Application name (app_name) key not set in config/deploy_kit.yml.'
    elsif @fu_conf[:s3_bucket] == 'some-s3-bucket'
      raise DeployKitConfigError, 'S3 bucket (s3_bucket) not set in config/deploy_kit.yml.  This bucket must be created using an external S3 tool like S3 Browser for OS X, or JetS3t (Java-based, cross-platform).'
    else
      # Check for access keys set as environment variables:
      if ENV.keys.include?('AMAZON_ACCESS_KEY_ID') && ENV.keys.include?('AMAZON_SECRET_ACCESS_KEY')
        @fu_conf[:aws_access_key_id] = ENV['AMAZON_ACCESS_KEY_ID']
        @fu_conf[:aws_secret_access_key] = ENV['AMAZON_SECRET_ACCESS_KEY']
      elsif @fu_conf[:aws_access_key_id].blank? || @fu_conf[:aws_access_key_id].include?('--replace me') || @fu_conf[:aws_secret_access_key].include?('--replace me')
        raise DeployKitConfigError, 'AWS Access Key Id or AWS Secret Key not set in config/deploy_kit.yml.'
      end
    end
  end

  def timestamp
    @timestamp ||= Time.now.strftime("%Y-%m-%d_%H%M%S")
  end

  def create_dirs
    ensure_directory_exists(backup_path)
  end

  def ensure_directory_exists(dir)
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
  end

  def backup_path
    @fu_conf[:dump_base_path] || File.join(RAILS_ROOT, 'backup')
  end

  def backup(store)
    raise 'Called abstract method: backup'
  end

  def cmd
    raise 'Called abstract method: cmd'
  end

  def final_filename
    raise 'Called abstract method: final_filename'
  end
end
