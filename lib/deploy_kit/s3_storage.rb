class S3storage < DeployKit
  def put(file)
    s3_connection
    file_name = File.basename(file)
    AWS::S3::S3Object.store(
      file_name, open(file), @fu_conf[:s3_bucket]
    )
  end

  def s3_connection
    @s3 ||= AWS::S3::Base.establish_connection!(
      :access_key_id     => @fu_conf[:aws_access_key_id],
      :secret_access_key => @fu_conf[:aws_secret_access_key]
    )
  end

  def list
    s3_connection
    AWS::S3::Bucket.find(@fu_conf[:s3_bucket]).objects.each do |file|
      puts "#{file.key.to_s.ljust(50)}  #{file.size}"
    end
  end
end
