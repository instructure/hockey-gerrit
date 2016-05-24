require_relative 'hockey_gerrit/version'
require 'English'

# Fix undefined method `command' for main:Object
# shenzhen depends on commander gem.
def command(_param)
end

require 'rubygems'
require 'shenzhen'
require 'shenzhen/plugins/hockeyapp'

module HockeyGerrit
  class << self
    def gerrit_refspec(gerrit = ENV['GERRIT_REFSPEC'])
      raise 'Must set GERRIT_REFSPEC' unless gerrit && !gerrit.empty?
      gerrit_split = gerrit.split('/')
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

    HOCKEY_TOKEN = ENV['HOCKEY_TOKEN']
    IPA = ARGV.first
    BUILD_URL = ENV['BUILD_URL']

    def configure_options
      gerrit = gerrit_refspec
      log = git_log
      release_notes = "#{gerrit}\n#{log}"

      markdown = 1
      available_for_download = 2
      dont_notify = 0
      options = {
          notes_type: markdown,
          notes: release_notes,
          notify: dont_notify,
          ipa: IPA,
          status: available_for_download,
          build_server_url: BUILD_URL,
          commit_sha: git_commit_sha
      }

      dysm = IPA.to_s.gsub('ipa', 'app.dSYM.zip')
      if File.exist?(dysm)
        options[:dsym] = dysm
      else
        is_android = File.extname(IPA) == '.apk'
        puts 'dSYM not found! Unable to symbolicate crashes' unless is_android
      end
      options
    end

    def hockey_url(response)
      config_url = response.body ? response.body['config_url'] : ''
      raise 'Missing config_url' unless config_url
      config_url.gsub!('https://upload.hockeyapp.net/', 'https://rink.hockeyapp.net/')
      config_url
    end

    def validate_args
      raise 'Must set HOCKEY_TOKEN' unless HOCKEY_TOKEN
      raise 'Must provide path to IPA' unless IPA
      raise 'IPA doesn\'t exist' unless File.exist?(IPA)
      raise 'Must provide BUILD_URL' unless BUILD_URL
    end

    def run
      validate_args

      tries = 5

      # http://support.hockeyapp.net/kb/api/api-versions#upload-version
      begin
        puts "Uploading #{File.basename(IPA)}"
        client = Shenzhen::Plugins::HockeyApp::Client.new(HOCKEY_TOKEN)

        options = configure_options
        response = client.upload_build(IPA, options)

        raise "Invalid response: #{response}" unless response.status == 201
        puts "Build uploaded to: #{hockey_url(response)}"
      rescue
        puts "Retrying upload. #{tries} attempts remaining..."
        retry unless (tries -= 1).zero?
        raise
      end
    end
  end
end
