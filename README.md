# Reruby [![Build Status](https://travis-ci.org/dgsuarez/reruby.svg?branch=master)](https://travis-ci.org/dgsuarez/reruby)

Automatic refactorings for Ruby.

**Warning** Alpha level code. Make sure to have your code committed before
running any Reruby command!!

## Available refactorings

### Rename Const

Rename classes or modules:

`reruby rename_const 'Some::Const' 'NewConstName'`

This will:

* Update occurrences of `Some::Const` to `Some::NewConstName`
* Rename the "main" file (`lib/some/const.rb`, `app/models/some/const.rb`...)
  and the test/spec file

Right now it won't, but should...

* Perform the rename when part of the namespace is `included` (it won't
  recognize `A::B` in `include A; B`)
* Handle the existence of classes/modules with the same name in nested lookup
  namespaces, if you have both `B::A` and `B::C::A`, and rename `B::A`, every
  usage of both will get replaced.

The current implementation uses syntactic analysis, so it won't be able to rename
usages that any kind of runtime knowledge, such as:

* `eval("Some::Const")`
*  `s = Some; s::Const`

Finally, Erb and such are not supported

### Extract method

Extract method refactoring:

`reruby extract_method -l some/path.rb:2:10:4:9 my_new_method`

This will:

* Find the code in `some/path.rb` starting on line 2, column 10 until line 4
  column 9.
* Append a new method `my_new_method` to the class where the code was defined,
  with the required arguments.
* Change the original code with an invocation to `my_new_method`, again with the
  required arguments.

Right now it won't, but should...

* Properly indent the new method definition.

### Explode Namespace

Extract classes or modules defined in the same file as their parent to a file
for each.

`reruby explode_namespace MyClass`

This will:

* Create new files (and folders if needed) for each class/module 1 level deep
  inside `MyClass` defined in the same file as `MyClass`
* Remove them from the `MyClass` file

Right now it won't, but should...

* Properly indent the outer class/module when creating new file
* Properly indent the newly added requires

### Instances to readers

Turn any instance variable read to a call to the reader method, adding the
`attr_reader` declaration as well.

`reruby instances_to_readers MyClass`

This will:

* Add `attr_reader var1, var2...`
* Change readings of `@var1`, `@var2` to `var1`, `var2`…

Right now it won't, but should...

* Properly indent the `attr_reader`

## Editor integration

Reruby reaches it's full potential when it's integrated in your text editor,
here's a list of available plugins. Please let us know which integrations you
would like to see, or if you know of an integration not available here.

* Vim [reruby.vim](https://github.com/dgsuarez/reruby.vim)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/dgsuarez/reruby.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

