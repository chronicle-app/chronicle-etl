# Chronicle::ETL

[![Gem Version](https://badge.fury.io/rb/chronicle-etl.svg)](https://badge.fury.io/rb/chronicle-etl)

Chronicle ETL is a utility that helps you archive and processes personal data. You can *extract* it from a variety of sources, *transform* it, and *load* it to an external API, file, or stdout.

This tool is an adaptation of Andrew Louis's experimental [Memex project](https://hyfen.net/memex) and the dozens of existing importers are being migrated to Chronicle.

## Installation

```bash
$ gem install chronicle-etl
```

## Usage

After installing the gem, `chronicle-etl` is available to run in your shell.

```bash
# read test.csv and display it as a table
$ chronicle-etl jobs:run --extractor csv --extractor-opts filename:test.csv --loader table

# Display help for the jobs:run command
$ chronicle-etl jobs help run
```

## Connectors

Connectors are available to read, process, and load data from different formats or external services.

```bash
# List all available connectors
$ chronicle-etl connectors:list
```

Built in connectors:

### Extractors
- `stdin` - (default) Load records from line-separated stdin
- `csv`
- `file` - load from a single file or directory (with a glob pattern)

### Transformers
- `null` - (default) Don't do anything

### Loaders
- `stdout` - (default) output transformed records to stdount
- `csv` - Load records to a csv file
- `table` - Output an ascii table of records. Useful for debugging.

### Provider-specific importers

In addition to the built-in importers, importers for third-party platforms are available. They are packaged as individual Ruby gems.

- [email](https://github.com/chronicle-app/chronicle-email). Extractors for `mbox` and other email files. Transformers for chronicle schema
- [bash](https://github.com/chronicle-app/chronicle-bash). Extract bash history from `~/.bash_history`. Transform it for chronicle schema

To install any of these, run `gem install chronicle-PROVIDER`. 

If you don't want to use the available rubygem importers, `chronicle-etl` can use `stdin` as an Extractor source (newline separated records). You can also use `stdout` as a loader — transformed records will be outputted separated by newlines.

I'll be open-sourcing more importers. Please [contact me](mailto:andrew@hyfen.net) to chat about what will be available!

### Full commands

```
$ chronicle-etl help 

ALL COMMANDS
  help                       # This help menu
  connectors help [COMMAND]  # Describe subcommands or one specific subcommand
  connectors:install NAME    # Installs connector NAME
  connectors:list            # Lists available connectors
  jobs help [COMMAND]        # Describe subcommands or one specific subcommand
  jobs:create                # Create a job
  jobs:list                  # List all available jobs
  jobs:run                   # Start a job
  jobs:show                  # Show a job
```

### Job options

```
Usage:
  chronicle-etl jobs:run

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

Everyone interacting in the Chronicle::ETL project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chronicle-app/chronicle-etl/blob/master/CODE_OF_CONDUCT.md).
