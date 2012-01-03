# REST assured

[![Build status](https://secure.travis-ci.org/BBC/REST-assured.png)](https://secure.travis-ci.org/BBC/REST-assured)

## Overview

A tool for stubbing/spying on http(s) based services that your app under test interacts with. This is useful for blackbox/integration testing.
There are three main use cases:

* stubbing out external data sources with predefined data
* verify requests to external services (aka spying)
* quickly simulate different behavior of external services using web UI; useful in development

## Usage

You are going to need ruby >= 1.8.7.

Rest-assured requires a database to run. Either sqlite or mysql. So, make sure there is one and its backed with corresponding client gem:

    bash$ gem install sqlite3 # or mysql2

If using mysql, rest-assured expects database 'rest\_assured' to be accessible by user 'root' with no password. Those are defaults and can be changed with cli options.

It is also recommended to have thin installed. This improves startup time (over default webrick) and also it works with in-memory sqlite (which webrick does not):

    bash$ gem install thin

Then install gem and run:

    bash$ gem install rest-assured
    bash$ rest-assured -a mysql &

Or clone from github and run:

    bash$ git clone git@github.com:BBC/rest-assured.git
    bash$ cd rest-assured && bundle install
    bash$ ./bin/rest-assured -d :memory: & # in-memory sqlite db

This starts up an instance of rest-assured on port 4578. It is accessible via REST or web interfaces on 'http://localhost:4578'

Various options (such as ssl, port, db credentials, etc.) are available through command line options. Check out `rest-assured -h` to see what they are.

NOTE that although sqlite is an extremely handy option (especially with :memory:), I found it sometimes locking tables under non-trivial load. Hence there is a Plan B - mysql. But may be that is just me sqliting it wrong.

## Doubles

Double is a stub/spy of HTTP request. Create a double that has the same request fullpath and method as the one your app is sending to a dependant service and then convience your app that rest-assured is that dependency (hint: by making endpoints configurable).

### Ruby Client API

Rest-assured provides client library to work with doubles. Check out 'Ruby API' section in [documentation](https://www.relishapp.com/artemave/rest-assured) for full reference.

Start up server instance first in env.rb/spec_helper.rb:

```ruby
require 'rest-assured'

RestAssured::Server.start(database: ':memory:', port: 7899) # or any other option available on command line
```
This server will be automatically shut down when your tests are done.

Alternatively, if you want to use existing server instance:

```ruby
RestAssured::Server.address = 'http://localhost:4578' # or wherever it is
```

You can now create doubles in your tests:

```ruby
RestAssured::Double.create(fullpath: '/products', content: 'this is content')
```

Now GET 'http://localhost:4578/products' will be returning 'this is content'.

You can also verify what requests happen on a double, or, in other words, spy on a double. Say this is a Given part of a test:

```ruby
@double = RestAssured::Double.create(fullpath: '/products', verb: 'POST')
```

Then let us assume that 'http://localhost:4578/products' got POSTed as a result of some actions in When part. Now we can examine requests happened on that double in Then part:

```ruby
@double.wait_for_requests(1, timeout: 10) # defaults to 5 seconds

req = @double.requests.first

req.body.should == expected_payload
JSON.parse(req.params).should == expected_params_hash
JSON.parse(req.rack_env)['ACCEPT'].should == 'text/html'
```

Use plain rest api to clear doubles/redirects between tests:

```ruby
RestClient.delete "#{RestAssured::Server.address}/redirects/all"
RestClient.delete "#{RestAssured::Server.address}/doubles/all"
```

### Plain REST API

For those using rest-assured from non-ruby environments.

#### Create double

  HTTP POST to '/doubles' creates a double and returns its json representation.
  The following options can be passed as request parameters:

  - __fullpath__ - e.g., '/some/api/object', or with parameters in query string (useful for doubling GETs) - '/some/other/api/object?a=2&b=c'. Mandatory.
  - __content__ - whatever you want this double to respond with. Optional.
  - __verb__ - one of http the following http verbs: GET, POST, PUT, DELETE. Optional. GET is default.
  - __status__ - status returned when double is requested. Optional. 200 is default.
  - __response_headers__ - key/value map of headers. Optional.
  
  Example:

    bash$ curl -d 'fullpath=/api/something&content=awesome&response_headers%5BContent-Type%5D=text%2Fhtml' http://localhost:4578/doubles
    {"double":{"active":true,"content":"awesome","description":null,"fullpath":"/api/something","id":1,"response_headers":{"Content-Type":"text/html"},"status":200,"verb":"GET"}}

    bash$ curl http://localhost:4578/api/something
    awesome

  If there is more than one double for the same fullpath and verb, the last created one gets served. In UI you can manually control which double is 'active' (gets served).

#### Get double state

  HTTP GET to '/doubles/:id.json' returns json with double current state. Use id from create json as :id.
  
  Example:
    
    bash$ curl http://localhost:4578/doubles/1.json | prettify_json.rb
    {
        "double": {
            "verb": "GET",
            "fullpath": "/api/something",
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
            "active": true
        }
    }

  The above assumes that that double has been requested once. Request history is in "requests" array (in chronological order). Each element contains the following data (keys):
  
  - __body__ - request payload
  - __params__ - request parameters. json
  - __created_at__ - request timestamp
  - __rack_env__ - raw request dump (json) including request headers

#### Delete all doubles

  HTTP DELETE to '/doubles/all' deletes all doubles. Useful for cleaning up between tests.

## Redirects

It is sometimes desirable to only double certain calls while letting others through to the 'real' services. Meet Redirects. Kind of "rewrite rules" for requests that didn't match any double. 

Another potential use for redirects is setting up a 'default' double that matches multiple fullpaths. This is of course given your app does not mind an extra redirect. Also note that 'default' double still covers single http verb so requests with different methods won't match.

Here is the rest API for managing redirects:

### Create redirect

  HTTP POST to '/redirects' creates redirect.
  The following options can be passed as request parameters:

  - __pattern__ - regex (perl5 style) tested against request fullpath. Mandatory
  - __to__ - url base e.g., 'https://myserver:8787/api'. Mandatory

  Example:
  
    bash$ curl -d 'pattern=^/auth&to=https://myserver.com/api' http://localhost:4578/redirects

  Now request (any verb) to 'http://localhost:4578/auth/services/1' will get redirected to 'https://myserver.com/api/'. Provided of course there is no double matched for that fullpath and verb. Captured group in pattern can be referenced from replacement e.g. \\1, \\2, etc.
  Much like rewrite rules, redirects are evaluated in order (of creation). In UI you can manually rearrange the order.

### Delete all redirects

  HTTP DELETE to '/redirects/all' deletes all redirects. Useful for cleaning up between tests.

## Author

[Artem Avetisyan](https://github.com/artemave)

## Changelog

#### 0.3 (12 Dec 2011)

* you can now specify response headers for double to respond with

#### 0.2

* adds verifications
* adds ruby client
* adds custom return statuses
* adds ssl
* adds mysql support

#### 0.1

* initial public release

