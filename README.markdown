# REST assured

## Overview

A tool for stubbing/mocking external http based services that your app under test interacts with. This is useful for blackbox/integration testing.
There are three main use cases:

* stubbing out external data sources with predefined data
* verify requests to external services
* quickly emulate different behavior of external services during development (using web UI)

## Usage

You are going to need ruby >= 1.8.7.

First make sure there is database adapter:

    bash$ gem install sqlite3 # or mysql

If using mysql, rest-assured expects database 'rest\_assured' to be accessible by user 'root' with no password. Those are defaults and can be changed with cli options.

Then install gem and run:

    bash$ gem install rest-assured
    bash$ rest-assured -a mysql &

Or clone from github and run:

    bash$ git clone git@github.com:BBC/rest-assured.git
    bash$ cd rest-assured && bundle install
    bash$ ./bin/rest-assured -d :memory: & # in-memory sqlite db

This starts an instance of rest-assured on port 4578. It is accessible via REST or web interfaces on 'http://localhost:4578'

Various options (such as ssl, port, db credentials, etc.) are available through command line options. Check out `rest-assured -h` to see what they are.

NOTE that although sqlite is an extremely handy option (especially with :memory:), I found it locking tables under non-trivial load. Hence there is mysql - more setup, but always works. But may be that is just me sqliting it wrong.

## REST API

### Doubles

Double is a stub/mock of HTTP request.

#### Ruby Client API

Rest-assured provides client library which partially implements ActiveResource (create and get). To make it available put the following in your test setup code (e.g. env.rb)

```ruby
require 'rest-assured/client'

RestAssured::Client.config.server_address = 'http://localhost:4578' # or wherever your rest-assured is
```

You can then create doubles in your tests:

```ruby
RestAssured::Double.create(fullpath: '/products', content: 'this is content')
```

Now GET 'http://localhost:4578/products' will be returning 'this is content'.

You can also verify what requests happen on a double. Say this is a Given part of a test:

```ruby
@double = RestAssured::Double.create(fullpath: '/products', verb: 'POST')
```

Then let us assume that 'http://localhost:4578/products' got POSTed as a result of some actions in When part. Now we can examine requests happened on that double in Then part:

```ruby
@double.wait_for_requests(1, :timeout => 10) # default timeout 5 seconds

req = @double.requests.first

req.body.should == expected_payload
JSON.parse(req.params).should == expected_params_hash
JSON.parse(req.rack_env)['ACCEPT'].should == 'Application/json'
```

Use plain rest api to clear doubles/redirects between tests:

```ruby
RestClient.delete "#{RestAssured::Client.config.server_address}/redirects/all"
RestClient.delete "#{RestAssured::Client.config.server_address}/doubles/all"
```


#### Plain REST API

 

##### Create double 
  HTTP POST to '/doubles' creates double and returns its json representation.
  The following options can be passed as request parameters:

  - __fullpath__ - e.g., '/some/api/object', or with parameters in query string (useful for doubling GETs) - '/some/other/api/object?a=2&b=c'. Mandatory.
  - __content__ - whatever you want this double to respond with. Optional.
  - __verb__ - one of http the following http verbs: GET, POST, PUT, DELETE. Optional. GET is default.
  - __status__ - status returned when double is requested. Optional. 200 is default.
  
  Example:

    bash$ curl -d 'fullpath=/api/something&content=awesome' http://localhost:4578/doubles
    {"double":{"active":true,"content":"awesome","description":null,"fullpath":"/api/something","id":2,"status":200,"verb":"GET"}}

    bash$ curl http://localhost:4578/api/something
    awesome

  If there is more than one double for the same fullpath and verb, the last created one gets served. In UI you can manually control which double is 'active' (gets served).

##### Get double state
  HTTP GET to '/doubles/:id.json' returns json with double current state. Use id from create json as :id.
  
  Example:
    
    bash$ curl http://localhost:4578/doubles/2.json
    {"double":{"active":true,"content":"awesome","description":null,"fullpath":"/api/something","id":2,"status":200,"verb":"GET","requests":[{"body":"","created_at":"2011-12-07T12:07:22+00:00","double_id":2,"id":2,"params":"{}","rack_env":"{\"SERVER_SOFTWARE\":\"thin 1.3.1 codename Triple Espresso\",\"SERVER_NAME\":\"localhost\",\"rack.version\":[1,0],\"rack.multithread\":false,\"rack.multiprocess\":false,\"rack.run_once\":false,\"REQUEST_METHOD\":\"GET\",\"REQUEST_PATH\":\"/api/something\",\"PATH_INFO\":\"/api/something\",\"REQUEST_URI\":\"/api/something\",\"HTTP_VERSION\":\"HTTP/1.1\",\"HTTP_USER_AGENT\":\"curl/7.19.7 (universal-apple-darwin10.0) libcurl/7.19.7 OpenSSL/0.9.8l zlib/1.2.3\",\"HTTP_HOST\":\"localhost:4578\",\"HTTP_ACCEPT\":\"*/*\",\"GATEWAY_INTERFACE\":\"CGI/1.2\",\"SERVER_PORT\":\"4578\",\"QUERY_STRING\":\"\",\"SERVER_PROTOCOL\":\"HTTP/1.1\",\"rack.url_scheme\":\"http\",\"SCRIPT_NAME\":\"\",\"REMOTE_ADDR\":\"127.0.0.1\",\"async.callback\":{},\"async.close\":{},\"rack.session\":{\"session_id\":\"bf08f065955d9aa68e77af9b916419558ca0d0ce47629d967c9882f503afb482\",\"tracking\":{\"HTTP_USER_AGENT\":\"06e79511d71287ca292dced4ef07c8fff9400376\",\"HTTP_ACCEPT_ENCODING\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\",\"HTTP_ACCEPT_LANGUAGE\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\"},\"__FLASH__\":{}},\"rack.session.options\":{\"key\":\"rack.session\",\"path\":\"/\",\"domain\":null,\"expire_after\":null,\"secure\":false,\"httponly\":true,\"defer\":false,\"renew\":false,\"sidbits\":128,\"secure_random\":{\"pid\":19776},\"secret\":\"16ca2e9c22e3cf1ce1724141b2031e1fa91fee92e8d818472ea38d68fffa64d886ff9a74ec9d7055d5925d063bd5f627f5717276da4b14485e1454ea5265d3b7\",\"coder\":{},\"id\":\"bf08f065955d9aa68e77af9b916419558ca0d0ce47629d967c9882f503afb482\"},\"rack.request.cookie_hash\":{},\"rack.session.unpacked_cookie_data\":{\"session_id\":\"bf08f065955d9aa68e77af9b916419558ca0d0ce47629d967c9882f503afb482\"},\"x-rack.flash\":{\"opts\":{\"sweep\":true},\"store\":{\"session_id\":\"bf08f065955d9aa68e77af9b916419558ca0d0ce47629d967c9882f503afb482\",\"tracking\":{\"HTTP_USER_AGENT\":\"06e79511d71287ca292dced4ef07c8fff9400376\",\"HTTP_ACCEPT_ENCODING\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\",\"HTTP_ACCEPT_LANGUAGE\":\"da39a3ee5e6b4b0d3255bfef95601890afd80709\"},\"__FLASH__\":{}},\"flagged\":[]},\"rack.request.query_string\":\"\",\"rack.request.query_hash\":{}}"}]}}

  The above assumes that that double has been requested once. Now take a look at 'requests' array. This is history of requests for that double (in chronological order). Each element contains the following data (keys):
  
  - __body__ - request payload
  - __params__ - request parameters. json
  - __created_at__ - request timestamp
  - __rack_env__ - raw request dump (json) including request headers

##### Delete all doubles
  HTTP DELETE to '/doubles/all' deletes all doubles. Useful for cleaning up between tests.

### Redirects

It is sometimes desirable to only double certain calls while letting others through to the 'real' services. Meet Redirects. Kind of "rewrite rules" for requests that didn't match any double. Here is the rest API for managing redirects:

#### Create redirect
  HTTP POST to '/redirects' creates redirect.
  The following options can be passed as request parameters:

  - __pattern__ - regex (perl5 style) tested against request fullpath. Mandatory
  - __to__ - url base e.g., 'https://myserver:8787/api'. Mandatory

  Example:
  
    bash$ curl -d 'pattern=^/auth&to=https://myserver.com/api' http://localhost:4578/redirects

  Now request (any verb) to 'http://localhost:4578/auth/services/1' will get redirected to 'https://myserver.com/api/auth/services/1.' Provided of course there is no double matched for that fullpath and verb.
  Much like rewrite rules, redirects are evaluated in order (of creation). In UI you can manually rearrange the order.

#### Delete all redirects
  HTTP DELETE to '/redirects/all' deletes all redirects. Useful for cleaning up between tests.

## TODO

* Hide wiring rest-assured into ruby project behind client api
* Bring UI upto date with rest-api (add verbs, statuses, request history)
* Add custom response headers

## Author

[Artem Avetisyan](https://github.com/artemave)

## Changelog

#### 0.2

* adds verifications
* adds ruby client
* adds custom return statuses
* adds ssl
* adds mysql support

#### 0.1 initial public release

