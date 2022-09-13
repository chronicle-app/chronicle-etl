## A CLI toolkit for extracting and working with your digital history

![chronicle-etl-banner](https://user-images.githubusercontent.com/6291/157330518-0f934c9a-9ec4-43d9-9cc2-12f156d09b37.png)

[![Gem Version](https://badge.fury.io/rb/chronicle-etl.svg)](https://badge.fury.io/rb/chronicle-etl) [![Ruby](https://github.com/chronicle-app/chronicle-etl/actions/workflows/ruby.yml/badge.svg)](https://github.com/chronicle-app/chronicle-etl/actions/workflows/ruby.yml) [![Docs](https://img.shields.io/badge/docs-rubydoc.info-blue)](https://www.rubydoc.info/gems/chronicle-etl/)

Are you trying to archive your digital history or incorporate it into your own projects? You’ve probably discovered how frustrating it is to get machine-readable access to your own data. While [building a memex](https://hyfen.net/memex/), I learned first-hand what great efforts must be made before you can begin using the data in interesting ways.

If you don’t want to spend all your time writing scrapers, reverse-engineering APIs, or parsing takeout data, this tool is for you! (*If you do enjoy these things, please see the [open issues](https://github.com/chronicle-app/chronicle-etl/issues).*)

**`chronicle-etl` is a CLI tool that gives you a unified interface to your personal data.** It uses the ETL pattern to *extract* data from a source (e.g. your local browser history, a directory of images, goodreads.com reading history), *transform* it (into a given schema), and *load* it to a destination (e.g. a CSV file, JSON, external API).

## What does `chronicle-etl` give you?
* **A CLI tool for working with personal data**. You can monitor progress of exports, manipulate the output, set up recurring jobs, manage credentials, and more.
* **Plugins for many third-party providers** (see [list](#available-plugins-and-connectors)). This plugin system allows you to access data from dozens of third-party services, all accessible through a common CLI interface.
* **A common, opinionated schema**: You can normalize different datasets into a single schema so that, for example, all your iMessages and emails are represented in a common schema. (Don’t want to use this schema? `chronicle-etl` always allows you to fall back on working with the raw extraction data.)

## Chronicle-ETL in action

![demo](https://user-images.githubusercontent.com/6291/161410839-b5ce931a-2353-4585-b530-929f46e3f960.svg)

### Longer screencast

[![asciicast](https://asciinema.org/a/483455.svg)](https://asciinema.org/a/483455)

## Installation

Using homebrew:
```sh
$ brew install chronicle-app/etl/chronicle-etl
```
Using rubygems:
```sh
$ gem install chronicle-etl
```

Confirm it installed successfully:
```sh
$ chronicle-etl --version
```

## Basic usage and running jobs

```sh
# Display help
$ chronicle-etl help

# Run a basic job 
$ chronicle-etl --extractor NAME --transformer NAME --loader NAME

# Read test.csv and display it to stdout as a table 
$ chronicle-etl --extractor csv --input data.csv --loader table

# Show available plugins and install one
$ chronicle-etl plugins:list
$ chronicle-etl plugins:install shell

# Retrieve shell commands run in the last 5 hours
$ chronicle-etl -e shell --since 5h

# Get email senders from an .mbox email archive file
$ chronicle-etl --extractor email:mbox -i sample-email-archive.mbox -t email --fields actor.slug

# Save an access token as a secret and use it in a job
$ chronicle-etl secrets:set pinboard access_token username:foo123
$ chronicle-etl secrets:list # Verify that's it's available
$ chronicle-etl -e pinboard --since 1mo # Used automatically based on plugin name
```

### Common options
```sh
Options:
  -e, [--extractor=NAME]                 # Extractor class. Default: stdin
      [--extractor-opts=key:value]       # Extractor options
  -t, [--transformer=NAME]               # Transformer class. Default: null
      [--transformer-opts=key:value]     # Transformer options
  -l, [--loader=NAME]                    # Loader class. Default: table
      [--loader-opts=key:value]          # Loader options
  -i, [--input=FILENAME]                 # Input filename or directory
      [--since=DATE]                     # Load records SINCE this date (or fuzzy time duration)
      [--until=DATE]                     # Load records UNTIL this date (or fuzzy time duration)
      [--limit=N]                        # Only extract the first LIMIT records
  -o, [--output=OUTPUT]                  # Output filename
      [--fields=field1 field2 ...]       # Output only these fields
      [--header-row], [--no-header-row]  # Output the header row of tabular output

      [--log-level=LOG_LEVEL]            # Log level (debug, info, warn, error, fatal)
                                         # Default: info
  -v, [--verbose], [--no-verbose]        # Set log level to verbose
      [--silent], [--no-silent]          # Silence all output
```

### Saving a job
You can save details about a job to a local config file (saved by default in `~/.config/chronicle/etl/jobs/JOB_NAME.yml`) to save yourself the trouble specifying options each time.

```sh
# Save a job named 'sample' to ~/.config/chronicle/etl/jobs/sample.yml
$ chronicle-etl jobs:save sample --extractor pinboard --since 10d

# Run the job
$ chronicle-etl jobs:run sample

# Show details about the job
$ chronicle-etl jobs:show sample

# Show all saved jobs
$ chronicle-etl jobs:list
```

## Connectors and plugins

Connectors let you work with different data formats or third-party providers.

### Built-in Connectors

`chronicle-etl` comes with several built-in connectors for common formats and sources.

```sh
# List all available connectors
$ chronicle-etl connectors:list
```

#### Extractors
- [`csv`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/csv_extractor.rb) - Load records from CSV files or stdin
- [`json`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/json_extractor.rb) - Load JSON (either [line-separated objects](https://en.wikipedia.org/wiki/JSON_streaming#Line-delimited_JSON) or one object)
- [`file`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/file_extractor.rb) - load from a single file or directory (with a glob pattern)

#### Transformers
- [`null`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/transformers/null_transformer.rb) - (default) Don’t do anything and pass on raw extraction data

#### Loaders
- [`table`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/loaders/table_loader.rb) - (default) Output an ascii table of records. Useful for exploring data.
- [`csv`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/extractors/csv_extractor.rb) - Load records to CSV
- [`json`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/loaders/json_loader.rb) - Load records serialized as JSON
- [`rest`](https://github.com/chronicle-app/chronicle-etl/blob/main/lib/chronicle/etl/loaders/rest_loader.rb) - Serialize records with [JSONAPI](https://jsonapi.org/) and send to a REST API

### Chronicle Plugins for third-party services

Plugins provide access to data from third-party platforms, services, or formats. Plugins are packaged as separate gems and can be installed through the CLI (under the hood, it's a `gem install chronicle-PLUGINNAME`)

#### Plugin usage

```bash
# List available plugins
$ chronicle-etl plugins:list

# Install a plugin
$ chronicle-etl plugins:install NAME

# Use a plugin
$ chronicle-etl plugins:install shell
$ chronicle-etl --extractor shell:history --limit 10

# Uninstall a plugin
$ chronicle-etl plugins:uninstall NAME
```
#### Available plugins and connectors

The following are the officially-supported list of plugins and their available connectors:

| Plugin                                                                      | Type        | Identifier       | Description                                  |
|-----------------------------------------------------------------------------|-------------|------------------|----------------------------------------------|
| [apple-podcasts](https://github.com/chronicle-app/chronicle-apple-podcasts) | extractor   | listens          | listening history of podcast episodes        |
| [apple-podcasts](https://github.com/chronicle-app/chronicle-apple-podcasts) | transformer | listen           | a podcast episode listen to Chronicle Schema |
| [email](https://github.com/chronicle-app/chronicle-email)                   | extractor   | imap             | emails over an IMAP connection               |
| [email](https://github.com/chronicle-app/chronicle-email)                   | extractor   | mbox             | emails from an .mbox file                    |
| [email](https://github.com/chronicle-app/chronicle-email)                   | transformer | email            | email to Chronicle Schema                    |
| [foursquare](https://github.com/chronicle-app/chronicle-foursquare)         | extractor   | checkins         | Foursqure visits                             |
| [foursquare](https://github.com/chronicle-app/chronicle-foursquare)         | transformer | checkin          | checkin to Chronicle Schema                  |
| [github](https://github.com/chronicle-app/chronicle-github)                 | extractor   | activity         | user activity stream                         |
| [imessage](https://github.com/chronicle-app/chronicle-imessage)             | extractor   | messages         | imessages from local macOS                   |
| [imessage](https://github.com/chronicle-app/chronicle-imessage)             | transformer | message          | imessage to Chronicle Schema                 |
| [pinboard](https://github.com/chronicle-app/chronicle-pinboard)             | extractor   | bookmarks        | Pinboard.in bookmarks                        |
| [pinboard](https://github.com/chronicle-app/chronicle-pinboard)             | transformer | bookmark         | bookmark to Chronicle Schema                 |
| [safari](https://github.com/chronicle-app/chronicle-safari)                 | extractor   | browser-history  | browser history                              |
| [safari ](https://github.com/chronicle-app/chronicle-safari )               | transformer | browser-history  | browser history to Chronicle Schema          |
| [shell](https://github.com/chronicle-app/chronicle-shell)                   | extractor   | history          | shell command history (bash / zsh)           |
| [shell](https://github.com/chronicle-app/chronicle-shell)                   | transformer | command          | command to Chronicle Schema                  |
| [spotify](https://github.com/chronicle-app/chronicle-spotify)               | extractor   | liked-tracks     | liked tracks                                 |
| [spotify](https://github.com/chronicle-app/chronicle-spotify)               | extractor   | saved-albums     | saved albums                                 |
| [spotify](https://github.com/chronicle-app/chronicle-spotify)               | extractor   | listens          | recently listened tracks (last 50 tracks)    |
| [spotify](https://github.com/chronicle-app/chronicle-spotify)               | transformer | like             | like to Chronicle Schema                     |
| [spotify](https://github.com/chronicle-app/chronicle-spotify)               | transformer | listen           | listen to Chronicle Schema                   |
| [spotify](https://github.com/chronicle-app/chronicle-spotify)               | authorizer  |                  | OAuth authorizer                             |
| [zulip](https://github.com/chronicle-app/chronicle-zulip)                   | extractor   | private-messages | private messages                             |
| [zulip](https://github.com/chronicle-app/chronicle-zulip)                   | transformer | message          | message to Chronicle Schema                  |


### Coming soon

A few dozen importers exist [in my Memex project](https://hyfen.net/memex/) and I'm porting them over to the Chronicle system. The [Chronicle Plugin Tracker](https://github.com/orgs/chronicle-app/projects/1/views/1) lets you keep track what's available and what's coming soon.

If you don't see a plugin for a third-party provider or data source that you're interested in using with `chronicle-etl`, [please open an issue](https://github.com/chronicle-app/chronicle-etl/issues/new). If you want to work together on a plugin, please [get in touch](#get-in-touch)!

In summary, the following **are coming soon**:
anki, arc, bear, chrome, facebook, firefox, fitbit, foursquare, git, github, goodreads, google-calendar, images, instagram, lastfm, shazam, slack, strava, things, twitter, whatsapp, youtube.

### Writing your own plugin

Additional connectors are packaged as separate ruby gems. You can view the [iMessage plugin](https://github.com/chronicle-app/chronicle-imessage) for an example.

If you want to load a custom connector without creating a gem, you can help by [completing this issue](https://github.com/chronicle-app/chronicle-etl/issues/23).

If you want to work together on a connector, please [get in touch](#get-in-touch)! 

#### Sample custom Extractor class
```ruby
module Chronicle
  module FooService
    class FooExtractor < Chronicle::ETL::Extractor
      register_connector do |r|
        r.identifier = 'foo'
        r.description = 'from foo.com'
      end

      setting :access_token, required: true

      def prepare
        @records = # load from somewhere
      end

      def extract
        @records.each do |record|
          yield Chronicle::ETL::Extraction.new(data: row.to_h)
        end
      end
    end
  end
end
```


## Secrets Management

If your job needs secrets such as access tokens or passwords, `chronicle-etl` has a built-in secret management system. 

Secrets are organized in namespaces. Typically, you use one namespace per plugin (`pinboard` secrets for the `pinboard` plugin). When you run a job that uses the `pinboard` plugin extractor, for example, the secrets from that namespace will automatically be included in the extractor's options. To override which secrets get included, you can use do it in the connector options with `secrets: ALT-NAMESPACE`.

Under the hood, secrets are stored in `~/.config/chronicle/etl/secrets/NAMESPACE.yml` with 0600 permissions on each file.

### Using the secret manager

```sh
# Save a secret under the 'pinboard' namespace
$ chronicle-etl secrets:set pinboard access_token username:foo123

# Set a secret using stdin
$ echo -n "username:foo123" | chronicle-etl secrets:set pinboard access_token

# List available secretes
$ chronicle-etl secrets:list

# Use 'pinboard' secrets in the pinboard extractor's options (happens automatically)
$ chronicle-etl -e pinboard --since 1mo

# Use a custom secrets namespace
$ chronicle-etl secrets:set pinboard-alt access_token different-username:foo123
$ chronicle-etl -e pinboard --extractor-opts secrets:pinboard-alt --since 1mo

# Remove a secret
$ chronicle-etl secrets:unset pinboard access_token
```

## Roadmap

- Keep tackling **new plugins**. See: [Chronicle Plugin Tracker](https://github.com/orgs/chronicle-app/projects/1)
- Add support for **incremental extractions** ([#37](https://github.com/chronicle-app/chronicle-etl/issues/37))
- **Improve stdin extractor and shell command transformer** so that users can easily integrate their own scripts/languages/tools into jobs ([#5](https://github.com/chronicle-app/chronicle-etl/issues/48))
- **Add documentation for Chronicle Schema**. It's found throughout this project but never explained.

## Development
After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Additional development commands
```bash
# run tests
bundle exec rake spec

# generate docs
bundle exec rake yard

# use Guard to run specs automatically
bundle exec guard
```

## Get in touch
- [@hyfen](https://twitter.com/hyfen) on Twitter
- [@hyfen](https://github.com/hyfen) on Github
- Email: andrew@hyfen.net

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/chronicle-app/chronicle-etl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct
Everyone interacting in the Chronicle::ETL project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/chronicle-app/chronicle-etl/blob/main/CODE_OF_CONDUCT.md).
