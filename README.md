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
  base_url: "https://consolidatedsdk.yodlee.com/yodsoap/srest/my-cobranded-path/v1.0",
  cobranded_username: "my-cobranded-user",
  cobranded_password: "my-cobranded-password"
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

### Configuring the proxy

If you're Yodlee account is like ours Yodlee will whitelist certain IPs for access and you'll need to proxy all of your API requests through that IP. You can set the proxy with the proxy_url key. Currently the proxy supports, http, https, and socks proxies. Simply set the proxy_url property in the config hash passed to YodleeApi and it should begin using the proxy. For example:

```
config = {
  base_url: "https://consolidatedsdk.yodlee.com/yodsoap/srest/my-cobranded-path/v1.0",
  cobranded_username: "my-cobranded-user",
  cobranded_password: "my-cobranded-password",
  proxy_url: "https://my-proxy-server-on-the-whitelist:my=proxy-port/"
}

yodlee_api = Yodlicious::YodleeApi.new(config)
```

### Working with Response

## Contributing

1. Fork it ( https://github.com/liftforward/yodlicious/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### Running the integration suite

To run the Yodlicious integration tests you'll need an approved yodlee account. This is more than the one offered here [https://devnow.yodlee.com/user/register]. (Some of the integration suite will work against the devnow APIs but not all. On my todo list is to separate them out to make testing easier.) The integration suite expects these values to be set in the following environment variables:
```
YODLEE_BASE_URL="https://consolidatedsdk.yodlee.com/yodsoap/srest/my-cobranded-path/v1.0"
YODLEE_COBRANDED_USERNAME="my-cobranded-user"
YODLEE_COBRANDED_PASSWORD="my-cobranded-password"
YODLICIOUS_PROXY_URL="https://my-proxy-server-on-the-whitelist:my=proxy-port/"
```
