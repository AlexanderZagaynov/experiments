base = File.basename __FILE__, '.*'
%w(

  application
  load_tasks

).each do |path|
  require_relative "#{base}/#{path}"
end
