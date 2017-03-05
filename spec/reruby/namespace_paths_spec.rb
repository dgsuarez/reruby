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

  subject(:namespace_paths) { Reruby::NamespacePaths.new(namespace: 'A::B::C', paths: paths) }

  it "gets the main folder" do
    expect(namespace_paths.main_folder).to eq("lib/")
  end

end
