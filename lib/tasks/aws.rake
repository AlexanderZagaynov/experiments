namespace aws: :dotenv do

  desc 'Display AWS_PROFILE'
  task :aws do
    puts ENV['AWS_PROFILE']
  end

end