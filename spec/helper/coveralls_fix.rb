# exclude from coverage:
require_relative '../../lib/hockey_gerrit/shenzhen'
require_relative 'trace_helper'

require 'coveralls'

module Coveralls
  def should_run?
    true
  end

  def will_run?
    true
  end
end if ENV['CI']

Coveralls.wear!
