module Refinements; end
require_relative 'core/patches'

using Refinements::RequirePatch
%w(
  prepend
  empties
  numeric
  ergo
  require
).each { |name| require_patch name }
