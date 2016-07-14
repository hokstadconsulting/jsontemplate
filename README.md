# JsonTemplate

A simple template processor to take a number of small, manageable JSON files, and generate
one bigger JSON file. Inspired by Amazon's CloudFormation JSON format, which uses JSON "directives"
embedded in JSON to expand parameters, process text etc. 

Our main use case, is in fact to be able to more easily put together things like CloudFormation
templates from smaller, more manageable chunks.

Current syntax is very limited; we'll be adding to it over time. Pull requests welcome, but if
you want to make larger changes, please open an issue to discuss it first.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jsontemplate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jsontemplate

## Usage

Write a JSON file. Insert directives to replace portions of the contents. E.g.:

```json
    {
        "Description": "Some CloudFormation project",
        "Resources": {"$DirMerge": "resources/*.json"}
    }
```

Above, the "$DirMerge" directive will parse each of the JSON files that matches the 
description, expand them as templates, and merge the result together to a single
object, using the base of the filename as the key, and replace it as the value
for "Resources". So, e.g. the only json-file in "resources" is "resources/FooBar.json"
which contains '{"Foo": "Bar"}', the resulting file would be:

```json
    {
        "Description": "Some CloudFormation project",
        "Resources": {"FooBar": {"Foo": "Bar"}}
    }
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/hokstadconsulting/jsontemplate )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
