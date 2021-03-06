require_relative 'helper/spec_helper'

describe HockeyGerrit do
  let(:gerrit_refspec) { 'refs/changes/13/70000/10' }
  let(:hockey) { HockeyGerrit.new }

  def hockey_run(opts = {})
    ipa = opts.fetch :ipa, ipa_path
    tries = opts.fetch :retry, 1
    hockey.run(token: '123',
               ipa: ipa,
               build_url: '345',
               gerrit: gerrit_refspec,
               retry: tries)
  end

  before do
    allow(hockey).to receive(:git_log) { 'bootstraponline: Stub git log' }
    allow(hockey).to receive(:git_commit_sha) { '123456789641603afe0572f3b4a91204791b012d' }
  end

  it 'posts app to hockey' do
    stub_valid_response

    hockey_run

    expect(hockey.upload_url).to eq(upload_url)

    save_real_post_request

    verify_post_request
  end

  it 'errors on no dsym' do
    stub_valid_response

    expect { hockey_run(ipa: fake_broken_path) }.to output(/dSYM not found!/).to_stdout
  end

  it 'retries on failure' do
    # return 4 failures then 1 success
    stub_request(:post, post_url).to_return(
      {status: 401},
      {status: 401},
      {status: 401},
      {status: 401},
      stub_valid_obj
    )

    expected = <<S
Uploading fake.ipa
Retrying upload. 5 attempts remaining...
Retrying upload. 4 attempts remaining...
Retrying upload. 3 attempts remaining...
Retrying upload. 2 attempts remaining...
Build uploaded to: #{upload_url}
S

    expect { hockey_run(retry: 5) }.to output(expected).to_stdout
  end

  it 'raises on error' do
    stub_request(:post, post_url).to_return(status: 401)

    expect { hockey_run }.to raise_error(/Invalid response/)
  end
end
