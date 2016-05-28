require 'rubygems'
require_relative 'coveralls_fix'
require_relative 'trace_helper'
require_relative '../../lib/hockey_gerrit'

require 'webmock/rspec'
require 'pry'

module SpecHelper
  def path_for(path)
    File.expand_path(File.join(__dir__, '..', 'fixtures', path))
  end

  module_function :path_for

  def ipa_path
    @ipa_path ||= path_for 'fake.ipa'
  end

  def dysm_path
    @dysm_path ||= path_for 'fake.app.dSYM.zip'
  end

  def fake_broken_path
    @fake_broken_path ||= path_for 'fake_broken'
  end

  def upload_request_path
    @expected_request_path ||= path_for 'upload_request.yml'
  end

  module_function :upload_request_path

  def self.disable_net
    File.exist?(upload_request_path)
  end

  def post_url # used by webmock
    'https://upload.hockeyapp.net/api/2/apps/upload'
  end

  def stub_valid_obj
    config_url = '{ "config_url": "https://upload.hockeyapp.net/manage/apps/123456/app_versions/9"}'
    headers = { 'Content-Type' => 'application/json' }
    {
        status: 201,
        body: config_url,
        headers: headers
    }
  end

  def stub_valid_response
    stub_request(:post, post_url).to_return(stub_valid_obj)
  end

  def ipa_data
    File.read(ipa_path).strip
  end

  def dysm_data
    File.read(dysm_path).strip
  end

  def verify_post_request
    expected_request_string = File.read(upload_request_path)

    # The request must contain the data for ipa/dsm.
    # If the upload code is broken then only the filename will be sent.
    expect(expected_request_string).to include(ipa_data)
    expect(expected_request_string).to include(dysm_data)

    expected_request = ::YAML.load(expected_request_string)

    %i[body method uri headers].each do |attr|
      expect(current_request.send(attr)).to eq(expected_request.send(attr))
    end
  end

  def current_request
    # WebMock::RequestSignature
    WebMock::RequestRegistry.instance.requested_signatures.hash.keys.first
  end

  def save_real_post_request
    unless File.exist?(upload_request_path)
      File.open(upload_request_path, 'w') do |f|
        f.write ::YAML.dump(current_request)
      end
      raise 'Recorded upload request. Now run the test again'
    end
  end
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.color = true
  config.include SpecHelper
end

# Disable network calls when the recorded fixture exists on disk.
if SpecHelper.disable_net
  WebMock.disable_net_connect!
else
  WebMock.allow_net_connect!
end
