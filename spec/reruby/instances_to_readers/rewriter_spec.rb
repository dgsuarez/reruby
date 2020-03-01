# frozen_string_literal: true

require 'spec_helper'

describe Reruby::InstancesToReaders::Rewriter do

  before :each do
    @rewriter = Reruby::InstancesToReaders::Rewriter.new(namespace: 'A')
    @nested_code = <<-CODE.strip_heredoc
      class B
        def ho
          "Ho" + @heyo
        end

        class A
          def hi
            "hi " + @person
          end
        end
      end
    CODE
  end

  it 'gets all the instance vars' do
    code = <<-CODE.strip_heredoc
      class A
        def hi
          "hi " + @person
        end

        def name
          @person
        end
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A

        attr_reader :person

        def hi
          "hi " + person
        end

        def name
          person
        end
      end
    CODE

    actual_refactored = inline_refactor(code, @rewriter)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it "doesn't change assigments" do
    code = <<-CODE.strip_heredoc
      class A
        def hi
          @person = "hi"
        end
      end
    CODE

    actual_refactored = inline_refactor(code, @rewriter)

    expect(actual_refactored).to eql(code)
  end

  it "works when there's inheritance" do
    code = <<-CODE.strip_heredoc
      class A < C
        def hi
          "hi " + @person
        end
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A < C

        attr_reader :person

        def hi
          "hi " + person
        end
      end
    CODE

    actual_refactored = inline_refactor(code, @rewriter)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'changes the inner namespace when nested' do
    expected_refactored = <<-CODE.strip_heredoc
      class B
        def ho
          "Ho" + @heyo
        end

        class A

          attr_reader :person

          def hi
            "hi " + person
          end
        end
      end
    CODE

    rewriter = Reruby::InstancesToReaders::Rewriter.new(namespace: 'B::A')
    actual_refactored = inline_refactor(@nested_code, rewriter)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'changes the outer namespace when nested' do
    expected_refactored = <<-CODE.strip_heredoc
      class B

        attr_reader :heyo

        def ho
          "Ho" + heyo
        end

        class A
          def hi
            "hi " + @person
          end
        end
      end
    CODE

    rewriter = Reruby::InstancesToReaders::Rewriter.new(namespace: 'B')
    actual_refactored = inline_refactor(@nested_code, rewriter)

    expect(actual_refactored).to eql(expected_refactored)

  end

end
