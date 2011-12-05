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

NOTE that although sqlite is an extremely handy option (especially in memory on), I found it locking tables under non-trivial load. Hence there is mysql - more setup, but always works. But may be that is just me sqliting it wrong.

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

#### Plain REST API

 

##### Create double 
  HTTP POST to '/doubles.json' creates double and returns its json representation.
  The following options can be passed as request parameters:

  - __fullpath__ - e.g., '/some/api/object', or with parameters in query string (useful for doubling GETs) - '/some/other/api/object?a=2&b=c'. Mandatory.
  - __content__ - whatever you want this double to respond with. Optional.
  - __verb__ - one of http the following http verbs: GET, POST, PUT, DELETE. Optional. GET is default.
  - __status__ - status returned when double is requested. Optional. 200 is default.

  Example (using ruby RestClient):
  
```ruby
response = RestClient.post 'http://localhost:4578/doubles', { fullpath: '/api/v2/products?type=fresh', verb: 'GET', content: 'this is list of products', status: 200 }
puts response.body
```
  Produces:

    "{\"double\":{\"fullpath\":\"/api/v2/products?type=fresh\",\"verb\":\"GET\",\"id\":123,\"content\":\"this is list of products\",\"description\":null,\"status\":null,\"active\":true}}"

  And then GETting 'http://localhost:4578/api/v2/products?type=fresh' (in browser for instance) should return "this is list of products".

  If there is more than one double for the same fullpath and verb, the last created one gets served. In UI you can manually control which double is 'active' (gets served).

##### Get double state
  HTTP GET to '/double/:id.json' returns json with double current state. Use id from create json as :id.

  Example (using ruby RestClient):

```ruby
response = RestClient.get 'http://localhost:4578/doubles/123.json'
puts response.body
```

  Assuming the above double has been requested once, this call would produce

    "{\"double\":{\"fullpath\":\"/api/v2/products?type=fresh\",\"verb\":\"GET\",\"id\":123,\"requests\":[{\"rack_env\":\"LOOK FOR YOUR HEADERS HERE\",\"created_at\":\"2011-11-07T18:34:21+00:00\",\"body\":\"\",\"params\":\"{}\"}],\"content\":\"this is list of products\",\"description\":null,\"status\":null,\"active\":true}}"

  The important bit here is 'requests' array. This is history of requests for that double (in chronological order). Each element contains the following data (keys):
  
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

  Example (using ruby RestClient):

```ruby
RestClient.post 'http://localhost:4578/redirects', { pattern: '^/auth', to: 'https://myserver.com/api' }
```

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

