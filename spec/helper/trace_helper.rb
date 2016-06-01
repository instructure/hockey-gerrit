# rubocop:disable Lint/LiteralInCondition
if false
  require 'trace_files'

  rbenv_gem_dir = File.join(Dir.home, '.rbenv/versions/2.3.1/lib/ruby/gems/2.3.0/gems/')
  vcr_gem = File.expand_path File.join(rbenv_gem_dir, 'vcr-3.0.3', 'lib', '**', '*.rb')

  targets = []
  targets += Dir.glob(vcr_gem)

  targets.map! do |t|
    File.expand_path t
  end

  puts "Tracing: #{targets}"

  TraceFiles.set trace: targets
end
