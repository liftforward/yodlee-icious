# Yodlicious

Yodlicisous is a ruby gem wrapping the Yodlee REST(ish) API. We had to build this for our integration with Yodlee which was somewhat more painfull than it should have been so we figured we share to be a good neighbor.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yodlicious'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install yodlicious

## Usage

### Configuration

We needed to use the Yodlee API both within a rails app and outside with multiple Yodlee connections concurrently. As such we provided both the option for a global default configuration and a instance specific configuration. For instance specific:

```ruby
require "yodlicious"

config = {
  base_url: ENV['YODLEE_BASE_URL'],
  cobranded_username: ENV['YODLEE_COBRANDED_USERNAME'],
  cobranded_password: ENV['YODLEE_COBRANDED_PASSWORD'],
  proxy_url: ENV['YODLICIOUS_PROXY_URL']
}

yodlee_api = Yodlicious::YodleeApi.new(config)

```

When in a Rails app it can be more convenient to use a global default configuration. To use global defaults:
```ruby
#/<myproject>/config/initializers/yodlicious.rb
require 'yodlicious'

#setting default configurations for Yodlicious
Yodlicious::Config.base_url = ENV['YODLEE_BASE_URL']
Yodlicious::Config.cobranded_username = ENV['YODLEE_COBRANDED_USERNAME']
Yodlicious::Config.cobranded_password = ENV['YODLEE_COBRANDED_PASSWORD']
Yodlicious::Config.proxy_url = ENV['YODLICIOUS_PROXY_URL'] //optional

#setting yodlicious logger to use the Rails logger
Yodlicious::Config.logger = Rails.logger
```
and wherever you want to use the api simply create a new one and it will pickup the global defaults. 
```ruby
yodlee_api = Yodlicious::YodleeApi.new
```
If for any reason you need to, you can pass a hash into the constructor and it will use any provided hash values over the defaults. Note this is done on each value not the entire hash.

You can also update an existing instances of the YodleeApi's configuration with the configure method. For example:
```ruby

yodlee_api = Yodlicious::YodleeApi.new { base_url: 'http://yodlee.com/blablabla' }

yodlee_api.configure { base_url: 'https://secure.yodlee.com/blablabla }

puts yodlee_api.base_url
```
will output
```
https://secure.yodlee.com/blablabla
```

### Running integration tests to verify

### Configuring the proxy

### Working with Response

## Contributing

1. Fork it ( https://github.com/liftforward/yodlicious/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
