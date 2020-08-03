# Chronicle::Etl

[![Gem Version](https://badge.fury.io/rb/chronicle-etl.svg)](https://badge.fury.io/rb/chronicle-etl)

Chronicle ETL is a utility tool for manipulating personal data. You can extract it from a variety of source, transform it, and load it to different APIs or file formats.

## Installation

```bash
$ gem install chronicle-etl
```

## Examples

After installing the gem, `chronicle-etl` is available to run in your shell.

```
chronicle-etl --extractor csv --extractor-opts filename:test.csv --loader table
cat test.csv | chronicle-etl --extractor csv --loader table
```

## Full usage

```
Commands:
  chronicle-etl help [COMMAND]  # Describe available commands or one specific command
  chronicle-etl job             # Runs an ETL job
```

### Job options

```
Usage:
  chronicle-etl job

Options:
  -e, [--extractor=extractor-name]      # Extractor class (available: stdin, csv, file)
                                        # Default: stdin
      [--extractor-opts=key:value]      # Extractor options
  -t, [--transformer=transformer-name]  # Transformer class (available: null)
                                        # Default: null
      [--transformer-opts=key:value]    # Transformer options
  -l, [--loader=loader-name]            # Loader class (available: stdout, csv, table)
                                        # Default: stdout
      [--loader-opts=key:value]         # Loader options
  -j, [--job=JOB]                       # Job configuration file

Runs an ETL job
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chronicle-app/chronicle-etl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Chronicle::Etl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chronicle-app/chronicle-etl/blob/master/CODE_OF_CONDUCT.md).
