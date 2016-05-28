require_relative 'helper/spec_helper'

describe HockeyGerrit do
  let(:hockey) { HockeyGerrit.new }

  it '#git_log' do
    log = hockey.git_log
    raise 'git_log fail' if log.empty?
  end

  it '#git_commit_sha' do
    log = hockey.git_commit_sha
    raise 'git_commit_sha fail' if log.empty?
  end
end
