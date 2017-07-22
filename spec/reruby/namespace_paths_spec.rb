require 'spec_helper'

describe Reruby::NamespacePaths do

  let(:paths) do
    [
      "spec/a/b/c_spec.rb",
      "lib/b_c.rb",
      "lib/c.rb",
      "lib/a/c.rb",
      "lib/a/b/c.rb",
      "spec/a/c_spec.rb"
    ]
  end

  let(:namespace_paths) { Reruby::NamespacePaths.new(namespace: 'A::B::C', paths: paths) }

  it "gets the root folder" do
    expect(namespace_paths.root_folder).to eq("lib/")
  end

  it "gets the main file" do
    expect(namespace_paths.main_path).to eq("lib/a/b/c.rb")
  end

  it "gets the test file" do
    expect(namespace_paths.test_path).to eq("spec/a/b/c_spec.rb")
  end


end
