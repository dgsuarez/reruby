require 'spec_helper'

describe Reruby::ExtractMethod::AddNewMethodRewriter do

  it 'replaces the code in the range with the given invocation' do
    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: 'def extracted(b); end',
      text_range: Reruby::TextRange.parse('4:4:5:10')
    )

    code = <<-CODE.strip_heredoc
      class A
        def something
          a = b
          c = 3
          b
        end

      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A
        def something
          a = b
          c = 3
          b
        end

      def extracted(b); end

      end
    CODE

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'replaces in the correct class' do
    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: 'def extracted(b); end',
      text_range: Reruby::TextRange.parse('5:0:6:100')
    )

    code = <<-CODE.strip_heredoc
      module B
        class A
          def something
            a = b
            c = 3
            b
          end

        end

        class C

        end
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      module B
        class A
          def something
            a = b
            c = 3
            b
          end

      def extracted(b); end

        end

        class C

        end
      end
    CODE

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'works for multi method classes' do
    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: 'def extracted(b); end',
      text_range: Reruby::TextRange.parse('5:0:6:100')
    )

    code = <<-CODE.strip_heredoc
      module B
        class A
          def something
            a = b
            c = 3
            b
          end

          def other_things; end

        end

        class C

        end
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      module B
        class A
          def something
            a = b
            c = 3
            b
          end

          def other_things; end

      def extracted(b); end

        end

        class C

        end
      end
    CODE

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'replaces correctly when the class has another nested' do
    code = <<-CODE.strip_heredoc
      class A
        def something
          a = b
          c = 3
          b
        end

        class C; end
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A
        def something
          a = b
          c = 3
          b
        end

        class C; end

      def extracted(b); end
      end
    CODE

    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: 'def extracted(b); end',
      text_range: Reruby::TextRange.parse('3:0:4:100')
    )

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'replaces correctly when there is no outer class or module' do
    code = <<-CODE.strip_heredoc
      def something
        a = b
        c = 3
        b
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      def something
        a = b
        c = 3
        b
      end

      def extracted(b); end
    CODE

    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: 'def extracted(b); end',
      text_range: Reruby::TextRange.parse('2:0:3:100')
    )

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

  it 'handles null destination' do
    extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
      method_definition: 'def extracted(b); end',
      text_range: Reruby::TextRange.parse('5:0:6:100'),
      destination: ''
    )

    code = <<-CODE.strip_heredoc
      class A
        def something
            a = b
            c = 3
            b
        end
      end

      class B
        puts "Hello, world"
      end
    CODE

    expected_refactored = <<-CODE.strip_heredoc
      class A
        def something
            a = b
            c = 3
            b
        end
      end
      
      class B
        puts "Hello, world"
      end

      def extracted(b); end
    CODE

    actual_refactored = inline_refactor(code, extractor)

    expect(actual_refactored).to eql(expected_refactored)
  end

    it 'handles non-matching destination' do
      extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
        method_definition: 'def extracted(b); end',
        text_range: Reruby::TextRange.parse('5:0:6:100'),
        destination: 'Buddy'
      )

      code = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end

        class B
          puts "Hello, world"
        end
      CODE

      expected_refactored = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end
        
        class B
          puts "Hello, world"
        end

        def extracted(b); end
      CODE

      actual_refactored = inline_refactor(code, extractor)

      expect(actual_refactored).to eql(expected_refactored)
    end

    it 'puts method in correct destination' do
      extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
        method_definition: 'def extracted(b); end',
        text_range: Reruby::TextRange.parse('5:0:6:100'),
        destination: 'Buddy'
      )

      code = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end

        class Buddy
          puts "Hello, world"
        end
      CODE

      expected_refactored = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end
        
        class Buddy
          puts "Hello, world"

        def extracted(b); end
        end
      CODE

      actual_refactored = inline_refactor(code, extractor)

      expect(actual_refactored).to eql(expected_refactored)
    end

    it 'puts method in correct destination class' do
      extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
        method_definition: 'def extracted(b); end',
        text_range: Reruby::TextRange.parse('5:0:6:100'),
        destination: 'Buddy'
      )

      code = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end

        class Buddy
          puts "Hello, world"
        end
      CODE

      expected_refactored = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end
        
        class Buddy
          puts "Hello, world"

        def extracted(b); end
        end
     CODE

      actual_refactored = inline_refactor(code, extractor)

      expect(actual_refactored).to eql(expected_refactored)
    end

    it 'puts method in correct destination module' do
      extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
        method_definition: 'def extracted(b); end',
        text_range: Reruby::TextRange.parse('5:0:6:100'),
        destination: 'Buddy'
      )

      code = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end

        module Buddy
          puts "Hello, world"
        end
      CODE

      expected_refactored = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end
        
        module Buddy
          puts "Hello, world"

        def extracted(b); end
        end
     CODE

      actual_refactored = inline_refactor(code, extractor)

      expect(actual_refactored).to eql(expected_refactored)
    end

    it 'puts method in correct destination when multiple classes' do
      extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
        method_definition: 'def extracted(b); end',
        text_range: Reruby::TextRange.parse('5:0:6:100'),
        destination: 'B'
      )

      code = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end

        class C
        end

        class B
          puts "Hello, world"
        end

        class D
        end
      CODE

      expected_refactored = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
        end

        class C
        end
        
        class B
          puts "Hello, world"

        def extracted(b); end
        end

        class D
        end
      CODE

      actual_refactored = inline_refactor(code, extractor)

      expect(actual_refactored).to eql(expected_refactored)
    end

    it 'puts method in nested destination' do
      extractor = Reruby::ExtractMethod::AddNewMethodRewriter.new(
        method_definition: 'def extracted(b); end',
        text_range: Reruby::TextRange.parse('5:0:6:100'),
        destination: 'C'
      )

      code = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
          class C
            puts "I'm in class C"
          end
        end
        class B
          puts "I'm in class B"
        end
      CODE

      expected_refactored = <<-CODE.strip_heredoc
        class A
          def something
              a = b
              c = 3
              b
          end
          class C
            puts "I'm in class C"

        def extracted(b); end
          end
        end
        class B
          puts "I'm in class B"
        end
      CODE

      actual_refactored = inline_refactor(code, extractor)

      expect(actual_refactored).to eql(expected_refactored)
    end

end