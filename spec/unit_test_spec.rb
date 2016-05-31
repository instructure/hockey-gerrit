require_relative 'helper/spec_helper'

describe HockeyGerrit do
  let(:hockey) { HockeyGerrit.new }

  it '#git_log' do
    expect(hockey.git_log).not_to be_empty
  end

  it '#git_commit_sha' do
    expect(hockey.git_commit_sha).not_to be_empty
  end
end
