require_relative 'hockey_gerrit/version'
require 'English'

require 'rubygems'
require_relative 'hockey_gerrit/shenzhen'

class HockeyGerrit
  attr_reader :token, :ipa, :build_url, :gerrit_env, :tries, :upload_url

  def gerrit_refspec
    raise 'Must set GERRIT_REFSPEC' unless gerrit_env && !gerrit_env.empty?
    gerrit_split = gerrit_env.split('/')
    raise 'GERRIT_REFSPEC is invalid' unless gerrit_split.size >= 2
    change, patch = gerrit_split[-2..-1]
    "g#{change},#{patch}"
  end

  def git_log
    git_log = `git log --reverse -1 --format="%an: %s"`
    raise 'command failed' unless $CHILD_STATUS.success?
    git_log
  end

  def git_commit_sha
    sha = `git rev-parse --verify HEAD`
    raise 'command failed' unless $CHILD_STATUS.success?
    sha
  end

  def configure_options
    gerrit = gerrit_refspec
    log = git_log
    release_notes = "#{gerrit}\n\n#{log}"

    markdown = 1
    available_for_download = 2
    dont_notify = 0
    options = {
        notes_type: markdown,
        notes: release_notes,
        notify: dont_notify,
        ipa: ipa,
        status: available_for_download,
        build_server_url: build_url,
        commit_sha: git_commit_sha
    }

    dsym_ext = 'app.dSYM.zip'
    dsym = ipa.to_s.gsub('ipa', dsym_ext)

    if File.exist?(dsym) && dsym.end_with?(dsym_ext)
      options[:dsym_filename] = dsym
    else
      is_android = File.extname(ipa) == '.apk'
      puts 'dSYM not found! Unable to symbolicate crashes' unless is_android
    end
    options
  end

  def hockey_url(response)
    config_url = response.body ? response.body['config_url'] : nil
    raise 'Missing config_url' unless config_url && !config_url.empty?
    config_url.gsub!('https://upload.hockeyapp.net/', 'https://rink.hockeyapp.net/')
    @upload_url = config_url
    config_url
  end

  def validate_args(opts)
    @token = opts.fetch :token, ENV['token']
    @ipa = opts.fetch :ipa, ARGV.first
    @build_url = opts.fetch :build_url, ENV['build_url']
    @gerrit_env = opts.fetch :gerrit, ENV['GERRIT_REFSPEC']
    @tries = opts.fetch :retry, 5

    raise 'Must set token' unless token && token.is_a?(String) && !token.empty?
    raise 'Must provide path to ipa' unless ipa
    raise 'ipa doesn\'t exist' unless File.exist?(ipa)
    raise 'Must provide build_url' unless build_url
    raise 'Retry must be an int >= 1' unless tries && tries.is_a?(Integer) && tries >= 1
  end

  def run(opts = {})
    validate_args opts

    tries = @tries # required for tries to be in scope for 'retry'

    puts "Uploading #{File.basename(ipa)}"

    # http://support.hockeyapp.net/kb/api/api-versions#upload-version
    begin
      client = Shenzhen::Plugins::HockeyApp::Client.new(token)

      options = configure_options
      response = client.upload_build(ipa, options)

      raise "Invalid response: #{response.body}" unless response.status == 201
      puts "Build uploaded to: #{hockey_url(response)}"
    rescue
      puts "Retrying upload. #{tries} attempts remaining..." if tries > 1
      retry unless (tries -= 1).zero?
      raise
    end
  end
end
