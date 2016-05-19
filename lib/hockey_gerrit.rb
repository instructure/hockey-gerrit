require_relative 'hockey_gerrit/version'
require 'English'

class HockeyGerrit
  attr_accessor :output_file, :change, :patch, :log, :log_line
  def changes(gerrit)
    raise 'No line from Gerrit provided' if gerrit.empty?
    gerrit_split = gerrit.split('/')
    raise 'ENV GERRIT_REFSPEC has invalid format' unless gerrit_split.size >= 2
    @change, @patch = gerrit_split[-2..-1]
  end

  def assign_log
    @log = `git log --reverse -1 --format="%an: %s"`
    raise 'log command failed' unless $CHILD_STATUS.success?
  end

  def write_file
    File.write(output_file, log_line)
  end

  def delete_file
    File.delete(output_file)
  end

  def change_line
    raise 'Change empty' if change.empty?
    raise 'Patch empty' if patch.empty?
    raise 'Log empty' if log.empty?
    @log_line = "g#{change},#{patch}\n#{log}"
  end

  def write
    @output_file = 'changelog.md'
    raise 'ENV GERRIT_REFSPEC not defined' unless ENV['GERRIT_REFSPEC']
    changes(ENV['GERRIT_REFSPEC'])
    assign_log
    change_line
    write_file
  end
end
