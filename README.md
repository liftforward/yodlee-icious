
# Yodlicious
[![Gem Version](https://badge.fury.io/rb/yodlicious.svg)](http://badge.fury.io/rb/yodlicious)  [![Code Climate](https://codeclimate.com/repos/556dcf7fe30ba00903005872/badges/9398ac76dbcae2084eeb/gpa.svg)](https://codeclimate.com/repos/556dcf7fe30ba00903005872/feed) [![Test Coverage](https://codeclimate.com/repos/556dcf7fe30ba00903005872/badges/9398ac76dbcae2084eeb/coverage.svg)](https://codeclimate.com/repos/556dcf7fe30ba00903005872/coverage)
[ ![Codeship Status for liftforward/yodlicious](https://codeship.com/projects/71603f00-9393-0132-dcd0-1a9a253548c0/status?branch=master)](https://codeship.com/projects/62288)

Yodlicisous is a ruby gem wrapping the Yodlee REST(ish) API. We had to build this for our integration with Yodlee which was somewhat more painful than it should have been so we figured we share to be a good neighbor.

![image of yodlicious](https://github.com/liftforward/yodlicious/blob/master/yodlicious.png)

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

## Working with the API

The Yodlee Api responses are somewhat varied (especially the errors) and as such we build Yodlicious as a pretty thin layer around their request/response model. We didn't attempt to map all their JSON responses into models or anything fancy like that. Instead we simply created a method for each API endpoint which takes the required parameters and return a response object. That said, Response object does provide some conveniences to make up for the inconsistent delivery of errors from Yodlee's APIs.

### Starting your cobranded session

Once you've configured an instance of the YodleeAPI the first thing you must do is start a Yodlee cobranded session. This is also a good rails console test to see if everything is configured correctly: 

```ruby
pry(main)> yodlee_api = Yodlicious::YodleeApi.new
pry(main)> response = yodlee_api.cobranded_login
pry(main)> response.success?
=> true
```
As you probably suspect the call to cobranded_login wraps the ```/authenticate/coblogin``` endpoint call. If this is a success the YodleeApi instance will cache the cobranded session id yodlee returned and use it on all subsequent api calls. You can also access this value if desired with YodleeApi#cobranded_session_token.

```
pry(main)> yodlee_api.cobranded_session_token
=> "12162013_1:a0b1ac3e32a2e656f8f5bd21de23ae1721ffd9dab8bee9f29811f5959bbf102f16c98354eba252bb030dc96e267bd2489a40562f18e09ee8ba9038d19280cc43"
```
At this point something has probably gone wrong for you and you want to see the response json from ```/authenticate/coblogin```. To do this simply use ```response#body```. 

```
pry(main)> response.body
=> {"Error"=>[{"errorDetail"=>"Invalid Cobrand Credentials"}]}
```

### Starting a user session

Once the cobranded session is active a number of API endpoints will work however most of the interesting ones require you to register or login under a user account. It is within these accounts that you can add the user's bank accounts and whatnot to aggregate their financial data. There are 3 methods offered to allow you to #register_user, #login_user, or do either #login_or_register_user. After executing any of these the user session will be started and the user's session token will be cached in the YodleeApi instance and used on subsequent calls to api endpoints. As with all api calls if the call was not successful you'll need to look at the body of the response to determine what went wrong. 

### Registering a new user

```
pry(main)> response = yodlee_api.register_user 'my-username', 'my-password123', 'my-email@my-domain.com'
pry(main)> yodlee_api.user_session_token
=> "12162013_1:69761d51a4010e6382ccb49b854513dbccad0f835a873d37884b68826acefaa5b8d41b634f4cc83d97d86e7df861f70860a4e4d8a3f08d5b5440eae504af5f19"
```

### Login existing user

```
pry(main)> response = yodlee_api.user_login 'my-username', 'my-password123'
pry(main)> yodlee_api.user_session_token
=> "12162013_1:69761d51a4010e6382ccb49b854513dbccad0f835a873d37884b68826acefaa5b8d41b634f4cc83d97d86e7df861f70860a4e4d8a3f08d5b5440eae504af5f19"
```

### Convenience for doing both

In case you have a situation where you don't know if the user is already registered there is #login_or_register_user

```
pry(main)> response = yodlee_api.login_or_register_user 'my-username', 'my-password123', 'my-email@my-domain.com'
pry(main)> yodlee_api.user_session_token
=> "12162013_1:69761d51a4010e6382ccb49b854513dbccad0f835a873d37884b68826acefaa5b8d41b634f4cc83d97d86e7df861f70860a4e4d8a3f08d5b5440eae504af5f19"
```
### other API methods

TODO

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
