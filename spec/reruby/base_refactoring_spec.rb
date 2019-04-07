require 'spec_helper'

describe Reruby::BaseRefactoring do

  def create_refactoring_class(skip_steps: [])
    Class.new(::Reruby::BaseRefactoring) do
      skip_steps.each do |step|
        skip_step step
      end

      def refactor; end
    end
  end

  before :each do
    @config = Reruby::Config.new(
      options: {
        'autocommit' => true,
        'rubocop_autofix' => true
      }
    )
  end

  it 'performs all non-skipped steps' do
    mock_refactoring_class = create_refactoring_class

    refactoring = mock_refactoring_class.new(config: @config)

    expect(refactoring).to receive(:autocommit)
    expect(refactoring).to receive(:autofix)
    expect(refactoring).to receive(:print_report)

    refactoring.perform
  end

  it "doesn't perform skipped steps" do
    mock_refactoring_class = create_refactoring_class(skip_steps: [:autofix])

    refactoring = mock_refactoring_class.new(config: @config)

    expect(refactoring).not_to receive(:autofix)
    allow(refactoring).to receive(:autocommit)
    allow(refactoring).to receive(:print_report)

    refactoring.perform
  end

  it 'skips steps because of configuration options' do
    mock_refactoring_class = create_refactoring_class
    config = Reruby::Config.new(
      options: {
        'autocommit' => false,
        'rubocop_autofix' => false
      }
    )

    refactoring = mock_refactoring_class.new(config: config)
    expect(refactoring).not_to receive(:autocommit)
    expect(refactoring).not_to receive(:autofix)
    allow(refactoring).to receive(:print_report)

    refactoring.perform
  end
end
