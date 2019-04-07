require 'spec_helper'

describe Reruby::NamespacePaths do

  let(:paths) do
    [
      'spec/a/b/c_spec.rb',
      'lib/b_c.rb',
      'lib/c.rb',
      'lib/a/c.rb',
      'lib/a/b/c.rb',
      'spec/a/c_spec.rb'
    ]
  end

  let(:namespace_paths) { Reruby::NamespacePaths.new(namespace: 'A::B::C', paths: paths) }

  it 'gets the root folder' do
    expect(namespace_paths.root_folder).to eq('lib/')
  end

  it 'gets the main file' do
    expect(namespace_paths.main_file).to eq('lib/a/b/c.rb')
  end

  it 'gets the test file' do
    expect(namespace_paths.test_file).to eq('spec/a/b/c_spec.rb')
  end

  it 'gets the main folder if it exists' do
    folder_ns = Reruby::NamespacePaths.new(namespace: 'A::B', paths: paths)

    expect(folder_ns.main_folder).to eq('lib/a/b')
  end

  it "gets nil when the folder doesn't exist" do
    folder_ns = Reruby::NamespacePaths.new(namespace: 'A::Z', paths: paths)

    expect(folder_ns.main_folder).to be_nil
  end

  it 'gets the test folder if it exists' do
    folder_ns = Reruby::NamespacePaths.new(namespace: 'A::B', paths: paths)

    expect(folder_ns.test_folder).to eq('spec/a/b')
  end

end
