module Rake
  module Patches
  end
end

base = File.basename __FILE__, '.*'
%w(

  namespace
  dsl
  application

).each do |path|
  require_relative "#{base}/#{path}"
end
