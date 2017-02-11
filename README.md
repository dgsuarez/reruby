# Reruby

Automatic refactors for Ruby.

**Warning** Alpha level code. Make sure to have your code committed before
running any Reruby command!!

## Dependencies

Either `ag` or `ack` need to be available in `$PATH`

## Available refactors

### Rename Const

Rename classes or modules:

`reruby rename_const 'Some::Const' 'NewConstName'`

This will:

* Update occurrences of `Some::Const` to `Some::NewConstName`
* Rename the "main" file (`lib/some/const.rb`, `app/models/some/const.rb`...)
  and the test/spec file

Right now it won't, but should...

* Update `requires`
* Rename paths other than the main/test file (for example the folder for
  a module is kept as it was)
* Perform the rename when part of the namespace is `included` (it won't
  recognize `B` in `include A; B`)
* Handle the existence of classes/modules with the same name in nested lookup
  namespaces, if you have both `B::A` and `B::C::A`, and rename `B::A`, every
  usage of both will get replaced.

The current implementation uses static analysis, so it won't be able to rename
usages that any kind of runtime knowledge, such as:

* `eval("Some::Const")`
*  `s = Some; s::Const`

Finally, Erb and such are not supported

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

