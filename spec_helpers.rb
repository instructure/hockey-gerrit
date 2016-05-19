require 'coveralls'
Coveralls.wear!

require_relative '../lib/hockey_gerrit'

RSpec.configure do |c|
  c.raise_errors_for_deprecations!
  c.color = true
end
