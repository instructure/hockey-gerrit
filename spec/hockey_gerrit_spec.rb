require_relative 'helper/spec_helper'

describe HockeyGerrit do
  let(:gerrit_refspec) { 'refs/changes/13/70000/10' }
  let(:hockey) { HockeyGerrit.new }

  before do
    allow(hockey).to receive(:git_log) { 'bootstraponline: Stub git log' }
    allow(hockey).to receive(:git_commit_sha) { '123456789641603afe0572f3b4a91204791b012d' }

    # Prevent WebMock from complaining we made an unregistered request in net disabled mode.
    config_url = '{ "config_url": "https://upload.hockeyapp.net/manage/apps/123456/app_versions/9"}'
    headers = { 'Content-Type' => 'application/json' }
    stub_request(:post, post_url).to_return(status: 201,
                                            body: config_url,
                                            headers: headers)
  end

  it 'posts app to hockey' do
    hockey.run(token: '123',
               ipa: ipa_path,
               build_url: '345',
               gerrit: gerrit_refspec,
               retry: 1)

    expected_url = 'https://rink.hockeyapp.net/manage/apps/123456/app_versions/9'
    expect(hockey.upload_url).to eq(expected_url)

    save_real_post_request

    verify_post_request
  end
end
