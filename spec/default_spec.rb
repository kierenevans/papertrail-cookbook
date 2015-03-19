require 'spec_helper'

describe 'papertrail::default' do
  let(:chef_run) {
    ChefSpec::SoloRunner.new(platform: 'ubuntu', version: '10.04') do |node|
      node.set['papertrail']['watch_files'] = {
        'test/file/name.jpg' => 'test_file'
      }
    end.converge(described_recipe)
  }

  it 'should require rsyslog' do
    expect(chef_run).to include_recipe 'rsyslog'
  end

  it 'should use the basename of the filename as the suffix for state file name' do
    expect(chef_run).to render_file('/etc/rsyslog.d/60-watch-files.conf').with_content('$InputFileName test/file/name.jpg')
    expect(chef_run).to render_file('/etc/rsyslog.d/60-watch-files.conf').with_content('$InputFileTag test_file')
    expect(chef_run).to render_file('/etc/rsyslog.d/60-watch-files.conf').with_content('$InputFileStateFile state_file_name_test_file')
  end

  it 'should use attributes to generate configuration' do
    expect(chef_run).to render_file('/etc/rsyslog.d/65-papertrail.conf').with_content('$ActionResumeRetryCount -1')
    expect(chef_run).to render_file('/etc/rsyslog.d/65-papertrail.conf').with_content('$ActionQueueMaxDiskSpace 100M')
    expect(chef_run).to render_file('/etc/rsyslog.d/65-papertrail.conf').with_content('$ActionQueueSize 100000')
    expect(chef_run).to render_file('/etc/rsyslog.d/65-papertrail.conf').with_content('$ActionQueueFileName papertrailqueue')
  end

  it 'should only set gtls transport for the current action' do
    expect(chef_run).to render_file('/etc/rsyslog.d/65-papertrail.conf').with_content('$ActionSendStreamDriver gtls')
  end
end
