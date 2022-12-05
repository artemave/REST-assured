# REST assured

[![Build status](https://secure.travis-ci.org/artemave/REST-assured.png)](https://travis-ci.org/artemave/REST-assured)
[![Gem Version](https://badge.fury.io/rb/rest-assured.png)](http://badge.fury.io/rb/rest-assured)

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Overview

Stub/spy http(s) based external dependencies in your integration/acceptance tests.

## Description

With REST-assured you can:

* in tests: replace external HTTP(S) based data sources with predefined data (stubbing)
* in tests: verify requests to external services (spying)
* in development: simulate different behavior of external services using web UI; it looks like this:

![web ui screenshot](https://dl.dropboxusercontent.com/s/cb801va6t3zejdv/fakeshit.png?dl=0)

REST-assured is a web server that can be started programmatically and configured at runtime (via ruby client library or REST api) to respond to any request with arbitrary content, status, headers, etc.

But why not to use [VCR](https://github.com/vcr/vcr) or [WebMock](https://github.com/bblimke/webmock) instead? Well, you certainly should. If you can. REST-assured was born on a project where code was written in Java and integration tests in Ruby. This may sound a bit crazy, but the world is full crazy things and if you find yourself in one, you might find REST-assured useful.

[Playground](http://fakesh.it/)

[Example project](https://github.com/artemave/REST-assured-example)

[Long-winded intro blog post](http://artemave.github.com/2012/05/27/stub-like-a-surgeon-spy-like-james-bond-with-rest-assured/)


## Set up

You are going to need ruby >= 2.2.2 and either sqlite3, postgres or mysql. Use 2.x version of this gem if you need to support an older ruby version (>= 1.9.3).

### In ruby project

```ruby
# Gemfile
gem 'sqlite3' # or mysql2 or pg
              # use 'jdbcsqlite3' or 'jdbcmysql' for jruby
gem 'rest-assured'

# env.rb/spec_helper.rb
require 'rest-assured'

RestAssured::Server.start(database: ':memory:') # or any other option available on command line
# Or you can specify an instance that is already running somewhere:
RestAssured::Server.address = 'http://wacky-duckling.herokuapp.com'
```

### Standalone instance

Install db client gem:

    $ gem install sqlite3 # or mysql2 or pg

If using mysql/postgres, create database `rest_assured` accessible by user `root` with no password. Those are defaults and can be changed with cli options.

Then install gem and run:

    $ gem install rest-assured
    $ rest-assured &

Or clone and run:

    $ git clone git://github.com/artemave/REST-assured.git
    $ cd REST-assured && bundle install
    $ ./bin/rest-assured -d :memory: & # in-memory sqlite db

This starts up an instance of rest-assured on port 4578. It is accessible via REST or web interfaces on `http://localhost:4578`

Various options (such as ssl, port, db credentials, etc.) are available through command line options. Check out `rest-assured -h` to see what they are.

You can also [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

## Usage

REST-assured can do two things: respond to a particular path and method (e.g. GET /stuff/v2?thing=1) and redirect requests based on a pattern (e.g. all /foo\* will redirect to http://example.com/bar). Both of these are available to create/read/delete/head/options in runtime via api.

### Ruby API

REST-assured provides ruby client library to work with doubles (but not redirects). Check out 'Ruby API' section in [live documentation](https://www.relishapp.com/artemave/rest-assured) for full reference.

Create double:

```ruby
RestAssured::Double.create(fullpath: '/products', content: 'this is content')
```

Alternatively using a regular expression for the path

```ruby
RestAssured::Double.create(pathpattern: /products\/[a-z]{10}\/?param=.*/, content: 'this is more content')
```

Now GET `http://localhost:4578/products` will be returning `this is content` and a GET to
`http://localhost:4578/products/coolprod22?param=foo` will be returning `this is more content`.

The pathpattern parameter must be a ruby Regexp object or a string containing a valid regular expression.

You can also verify what requests happen on a double (spy on it). Say this is a Given part of a test:

```ruby
@double = RestAssured::Double.create(fullpath: '/products', verb: 'POST')
```

Then let us assume that `http://localhost:4578/products` got POSTed as a result of some actions in When part. Now we can examine requests happened on that double in Then part:

```ruby
@double.wait_for_requests(1, timeout: 10) # defaults to 5 seconds
# or, if waiting for specific amount of requests does not suit the test, just
@double.reload # before verifying

req = @double.requests.first

req.body.should == some_expected_payload
JSON.parse(req.params).should == expected_params_hash
JSON.parse(req.rack_env)['HTTP_ACCEPT'].should == 'text/html'
```

If you want to simulate a delayed time to first byte to test how your application handles latency or time outs you can
use the delay property when you create the double.

```ruby
 @double = RestAssured::Double.create(fullpath: '/slow-products', delay: 5)
```

Now, when a request is made to `http://localhost:4578/slow-products`, then the server will pause for 5 seconds before responding.

Use REST api to clear doubles/redirects between tests:

```ruby
RestClient.delete "#{RestAssured::Server.address}/redirects/all"
RestClient.delete "#{RestAssured::Server.address}/doubles/all"
```

### REST API

For using REST-assured from non-ruby environments.

#### Create double

  HTTP POST to `/doubles.json` creates a double and returns its json representation.
  The following options can be passed as request parameters:

  - __fullpath__ - e.g., `/some/api/object`, or with parameters in query string (useful for doubling GETs) - `/some/other/api/object?a=2&b=c`. Mandatory.
  - __content__ - whatever you want this double to respond with. Optional.
  - __verb__ - one of http the following http verbs: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`. Optional. `GET` is default.
  - __status__ - status returned when double is requested. Optional. `200` is default.
  - __response_headers__ - key/value map of headers. Optional.
  - __delay__ - the length of time in seconds the server should pause before sending the response.  Optional.
  
  Example:

```
    $ curl -d 'fullpath=%2Fapi%2Fsomething%5C%3Fparam%3D.*&content=awesome&response_headers%5BContent-Type%5D=text%2Fhtml' http://localhost:4578/doubles
    {"double":{"active":true,"content":"awesome","description":null,"fullpath":"/api/something","id":1,"response_headers":{"Content-Type":"text/html"},"status":200,"verb":"GET"}}

    $ curl http://localhost:4578/api/something
    awesome
```
  Example using a regular expression for the path:
  ```
      $ curl -d 'pathpattern=/api/something\?param=.*&content=awesome&response_headers%5BContent-Type%5D=text%2Fhtml' http://localhost:4578/doubles
      {"double":{"active":true,"content":"awesome","description":null,"pathpattern":"/api/something\?param=.*","id":1,"response_headers":{"Content-Type":"text/html"},"status":200,"verb":"GET"}}

      $ curl http://localhost:4578/api/something?param=foo
      awesome
  ```

  If there is more than one double for the same fullpath and verb, the last created one gets served.
  Doubles with `fullpath`'s are served in preference to `pathpattern`'s.
  In UI you can manually control which double is 'active' (gets served).

#### Get double state

  HTTP GET to `/doubles/:id.json` returns json with double current state. Use id from create json as `:id`.
  
  Example:
    
    $ curl http://localhost:4578/doubles/1.json | prettify_json.rb
    {
        "double": {
            "verb": "GET",
            "fullpath": "/api/something",
            "pathpattern" : null,
            "response_headers": {
                "Content-Type": "text/html"
            },
            "id": 1,
            "requests": [
                {
                    "double_id": 1,
                    "created_at": "2011-12-12T11:13:33+00:00",
                    "body": "",
                    "rack_env": "{\"SERVER_SOFTWARE\":\"thin 1.3.1 codename Triple Espresso\",\"SERVER_NAME\":\"localhost\",\"rack.version\":[1,0],\"rack.multithread\":false,\"rack.multiprocess\":false,\"rack.run_once\":false,\"REQUEST_METHOD\":\"GET\",\"REQUEST_PATH\":\"/api/something\",\"PATH_INFO\":\"/api/something\",\"REQUEST_URI\":\"/api/something\",\"HTTP_VERSION\":\"HTTP/1.1\",\"HTTP_USER_AGENT\":\"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\",\"HTTP_HOST\":\"localhost:4578\",\"HTTP_ACCEPT\":\"*/*\",\"GATEWAY_INTERFACE\":\"CGI/1.2\",\"SERVER_PORT\":\"4578\",\"QUERY_STRING\":\"\",\"SERVER_PROTOCOL\":\"HTTP/1.1\",\"rack.url_scheme\":\"http\",\"SCRIPT_NAME\":\"\",\"REMOTE_ADDR\":\"127.0.0.1\",\"async.callback\":{},\"async.close\":{},\"rack.session\":{\"session_id\":\"2d206d4edb880d41ae098bf0551c6904a4914f8632d101606b5304d4f651ce52\",\"tracking\":{\"HTTP_USER_AGENT\":\"06e79511d71287ca292dced4ef07c8fff9400376\",\"HTTP_ACCEPT_ENCODING\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\",\"HTTP_ACCEPT_LANGUAGE\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\"},\"__FLASH__\":{}},\"rack.session.options\":{\"key\":\"rack.session\",\"path\":\"/\",\"domain\":null,\"expire_after\":null,\"secure\":false,\"httponly\":true,\"defer\":false,\"renew\":false,\"sidbits\":128,\"secure_random\":{\"pid\":7885},\"secret\":\"bf80c75d713c92d2e3f94ea58be318c3f8988a3ed79d997f9cf883cc7aab1141225477ed81da7fe62ac77ecac3f979d255328dcbe8caa1bb342f4be6cb850983\",\"coder\":{},\"id\":\"2d206d4edb880d41ae098bf0551c6904a4914f8632d101606b5304d4f651ce52\"},\"rack.request.cookie_hash\":{},\"rack.session.unpacked_cookie_data\":{\"session_id\":\"2d206d4edb880d41ae098bf0551c6904a4914f8632d101606b5304d4f651ce52\"},\"x-rack.flash\":{\"opts\":{\"sweep\":true},\"store\":{\"session_id\":\"2d206d4edb880d41ae098bf0551c6904a4914f8632d101606b5304d4f651ce52\",\"tracking\":{\"HTTP_USER_AGENT\":\"06e79511d71287ca292dced4ef07c8fff9400376\",\"HTTP_ACCEPT_ENCODING\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\",\"HTTP_ACCEPT_LANGUAGE\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\"},\"__FLASH__\":{}},\"flagged\":[]},\"rack.request.query_string\":\"\",\"rack.request.query_hash\":{}}",
                    "id": 1,
                    "params": "{}"
                }
            ],
            "content": "awesome",
            "description": null,
            "status": 200,
            "active": true,
            "delay" : 0
        }
    }

  The above assumes that that double has been requested once. Request history is in `requests` array (in chronological order). Each element contains the following data (keys):
  
  - __body__ - request payload
  - __params__ - request parameters. json
  - __created_at__ - request timestamp
  - __rack_env__ - raw request dump (json) including request headers

#### Delete all doubles

  HTTP DELETE to `/doubles/all` deletes all doubles. Useful for cleaning up between tests.

## Redirects

It is sometimes desirable to only double certain calls while letting others through to the "real" services. Meet Redirects. Kind of "rewrite rules" for requests that didn't match any double. 

Another use for redirects is setting up a "default" double that matches multiple fullpaths. If a redirect pattern matches a defined double then it will act like a double and respond directly.  If it does not match a double then it will return HTTP 303 redirect instead.  Note that HTTP redirects are usually converted to GET requests by HTTP clients.

Here is the rest API for managing redirects:

### Create redirect

  HTTP POST to `/redirects.json` creates redirect.
  The following options can be passed as request parameters:

  - __pattern__ - regex (perl5 style) tested against request fullpath. e.g, `^/auth/(.*)`. Mandatory
  - __to__ - url base e.g, `http://example.com/api/\1?p=1` where `\1` is a reference to captured group from the pattern. Mandatory

  Example:

```  
    $ curl -d 'pattern=^/auth&to=https://myserver.com/api' http://localhost:4578/redirects
```

  Now request (any verb) to `http://localhost:4578/auth/services/1` will get redirected to `https://myserver.com/api/`. Provided of course there is no double matched for that fullpath and verb. Captured group in pattern can be referenced from replacement e.g. `\1`, `\2`, etc.
  Much like rewrite rules, redirects are evaluated in order (of creation). In UI you can manually rearrange the order.

### Delete all redirects

  HTTP DELETE to `/redirects/all` deletes all redirects. Useful for cleaning up between tests.
  
## Running tests

Tests require postgres. Connection params are read from environment variables `DB_HOST`, `DB_PORT` and `DB_USER` (defaults are `localhost`, `5432` and `postgres`). Cucumber tests also need Chrome.

    $ git clone git://github.com/artemave/REST-assured.git
    $ cd rest-assured && bundle install
    $ bundle exec rspec spec
    $ bundle exec cucumber

## Author

[Artem Avetisyan](https://github.com/artemave)
