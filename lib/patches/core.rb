base = File.basename __FILE__, '.*'
%w(

  setup
  patches
  prepend
  empties
  numeric
  glob
  file
  ergo

).each { |path| require_relative "#{base}/#{path}" }
