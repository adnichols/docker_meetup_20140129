require_relative 'spec_helper'

describe 'cook_docker::default' do
  subject { ChefSpec::Runner.new.converge described_recipe }

  describe 'should create a file' do
    it { should create_cookbook_file("/tmp/foo").with(owner: 'root', group: 'root', mode: '755') }
  end
end
