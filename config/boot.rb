require_relative '../lib/patches/core'

ENV['BUNDLE_GEMFILE'] ||= File.expand_path '../../Gemfile', __FILE__
require 'bundler/setup'
