# Reruby

Automatic refactors for Ruby.

**Warning** Alfa level code. Make sure to have your code committed before
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

It won't (...yet?)

* Update requires
* Update Erb files or others in non pure Ruby languages
* Rename usages of the const in non static ways (i.e. `"Some::Const".constatize`,
  `s = Some; s::Const`, ...)
* Others?

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

