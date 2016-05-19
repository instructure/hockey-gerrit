require_relative 'spec_helper'

describe 'Hockey-Gerrit' do
  describe 'Variable test' do
    let(:changes) { 'g70000,10' }
    let(:changeTest) { '70000' }
    let(:patchTest) { '10' }
    let(:success) { 1 }
    let(:output_file) { 'outputTest.md' }
    let(:log) { 'John Doe: Made a cool commit' } # This isn't a very good test...
    let(:changeTestString) { 'refs/changes/13/70000/10' }
    let(:gerrit_error) { 'ENV GERRIT_REFSPEC not defined' }
    let(:gerrit_format_error) { 'ENV GERRIT_REFSPEC has invalid format' }
    let(:empty_string_error) { 'Change/Patch empty' }
    test_module = HockeyGerrit.new

    it 'reject if gerrit variable not set' do
      expect { test_module.write }.to raise_error(RuntimeError, gerrit_error)
    end

    it 'raises exception if gerrit path is not formatted correctly' do
      expect { test_module.changes('invalid string') }.to raise_error(RuntimeError, gerrit_format_error)
      expect { test_module.changes(changeTestString) }.not_to raise_error
    end

    it 'set variables' do
      test_module.log = log
      expect(test_module.change).to eq changeTest
      expect(test_module.patch).to eq patchTest
      expect(test_module.log).to eq log
      # could try a regex above, but that would require git installed and on branch
      expect(test_module.change_line).to include changes
    end

    it 'write to File' do
      test_module.output_file = output_file
      expect(File.exist?(test_module.output_file)).to be false
      expect(test_module.write_file).to eq test_module.change_line.size
      expect(File.exist?(test_module.output_file)).to be true
    end

    it 'read the File' do
      arr = []
      File.readlines(test_module.output_file).each do |line|
        arr << line
      end
      expect(arr[0]).to include changes
      expect(arr[1]).to include log
    end

    it 'remove the file' do
      expect(File.exist?(test_module.output_file)).to be true
      expect(test_module.delete_file).to eq success
      expect(File.exist?(test_module.output_file)).to be false
    end
  end
end
