require 'spec_helper'

describe Reruby::InstancesToReaders do

  it "reports the files that changed in the refactoring" do
    finder_double = instance_double(
      Reruby::FileFinder,
      paths_containing_word: ["lib/a.rb"]
    )

    action_double = instance_double(
      Reruby::Actions::FileRewrite,
      perform: nil,
      changed?: true
    )

    allow(Reruby::FileFinder).to receive(:new) { finder_double }
    allow(Reruby::Actions::FileRewrite).to receive(:new) { action_double }

    refactoring = Reruby::InstancesToReaders.new(
      namespace: "A",
      config: config_with_json_report
    )

    expect(refactoring).to receive(:print).with(%r{changed.*lib/a.rb}m)

    refactoring.perform
  end

end
