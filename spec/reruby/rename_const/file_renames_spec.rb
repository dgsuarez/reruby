require 'spec_helper'

describe Reruby::RenameConst::FileRenames do

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

  subject(:renames) { Reruby::RenameConst::FileRenames.new(from: 'A::B::C', to: 'Z') }

  it "detects the rename for the main_file" do
    expect(renames.main_file_rename(paths)).to eq(["lib/a/b/c.rb", "lib/a/b/z.rb"])
  end

  it "gets the main file as the shortest matching path" do
    paths = [
      "lib/d/a/b/c.rb",
      "lib/j/a/b/c.rb",
      "lib/a/b/c.rb"
    ]
    expect(renames.main_file_rename(paths)).to eq(["lib/a/b/c.rb", "lib/a/b/z.rb"])
  end

  it "looks for the full path of the file" do
    renames = Reruby::RenameConst::FileRenames.new(from: 'C', to: 'Z')

    expect(renames.main_file_rename(paths)).to eq(["lib/c.rb", "lib/z.rb"])

  end

  it "detects the rename for the test file" do
    expect(renames.test_file_rename(paths)).to eq(["spec/a/b/c_spec.rb", "spec/a/b/z_spec.rb"])
  end

  it "gives both as renames" do
    expect(renames.renames(paths)).to include(["spec/a/b/c_spec.rb", "spec/a/b/z_spec.rb"])
    expect(renames.renames(paths)).to include(["lib/a/b/c.rb", "lib/a/b/z.rb"])
  end

  it "doesn't break if it can't find files" do
    expect(renames.renames([])).to be_empty
  end

end
