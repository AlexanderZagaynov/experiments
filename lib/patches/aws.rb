class Aws::Plugins::RegionalEndpoint

  # donator = Aws::SharedCredentials.new path: SecureRandom.hex, profile_name: SecureRandom.hex
  # %i(ini_parse).each do |method_name|
  #   define_method method_name, donator.method(method_name).to_proc
  # end
  # donator = nil

  option :region do |config|
    return config.region unless config.region.nil? || config.region.empty?

    donator   = Aws::SharedCredentials.new path: SecureRandom.hex, profile_name: SecureRandom.hex
    ini_parse = donator.method(:ini_parse).to_proc
    donator   = nil

    profile_name = "profile #{ENV['AWS_PROFILE']}"
    config_path  = File.join Dir.home, '.aws', 'config'
    profiles     = ini_parse.call File.read config_path

    profiles.dig profile_name, 'region'
  end
end
