# REST assured

## Overview

A tool for stubbing/mocking external http based services that your app under test interacts with. This is useful for blackbox/integration testing.
There are three main use cases:

* stubbing out external data sources with predefined data
* verify requests to external services
* quickly emulate different behavior of external services during development (using web UI)

## Usage

You are going to need ruby >= 1.8.7. Make sure database adapter present:

    bash$ gem install mysql # or sqlite

If using mysql, rest-assured expects database 'rest\_assured' to be accessible by user 'root' with no password. Those are defaults and are changeable with command line options.

Then install gem and run:

    bash$ gem install rest-assured
    bash$ rest-assured -a mysql &

Or clone from github and run:

    bash$ git clone git@github.com:BBC/rest-assured.git
    bash$ cd rest-assured && bundle install
    bash$ ./bin/rest-assured -a mysql &

This starts an instance of rest-assured on port 4578 (changable with --port option). You can now access it via REST or web interfaces on http://localhost:4578

NOTE that although sqlite is an option, I found it locking under any non-trivial load. Mysql feels much more reliable. But may be that is me sqliting it wrong.

### Plain REST API

#### Doubles

If your tests are in ruby (e.g. cucumber) then skip this section and check out Ruby Client API instead.

Double is a stub/mock of a particular external call. There is the following rest API for setting up doubles:

* `POST '/doubles.json', { fullpath: path, content: content, verb: verb, status: status }`
  Creates double with the following parameters:

  - __fullpath__ - e.g., `/some/api/object`, or with parameters in query string (useful for doubling GETs) - `/some/other/api/object?a=2&b=c`. Mandatory.
  - __content__ - whatever you want this double to respond with. Mandatory.
  - __verb__ - one of http the following http verbs: GET, POST, PUT, DELETE. Optional. GET is default.
  - __status__ - status returned when double is requested. Optional. 200 is default.

  Example (using ruby RestClient):
  
    RestClient.post 'http://localhost:4578/doubles', { fullpath: '/api/v2/products?type=fresh', verb: 'GET', content: 'this is list of products', status: 200 }

  And then GETting http://localhost:4578/api/v2/products?type=fresh (in browser for instance) should return "this is list of products".

  If there is more than one double for the same fullpath and verb, the last created one gets served. In UI you can manually control which double is 'active' (gets served).

  Returns json representation of a created double:

    "{\"double\":{\"fullpath\":\"/api/v2/products?type=fresh\",\"verb\":\"GET\",\"id\":123,\"content\":\"this is list of products\",\"description\":null,\"status\":null,\"active\":true}}"

  You can then use id from that json to make verification calls on that double.

* `GET '/double/:id.json'`
  Gets double current state. Use id from create json as :id.

  Example (using ruby RestClient):

    RestClient.get 'http://localhost:4578/doubles/123.json'

  Assuming the above double has been requested once, this call would return

    "{\"double\":{\"fullpath\":\"/api/v2/products?type=fresh\",\"verb\":\"GET\",\"id\":123,\"requests\":[{\"rack_env\":\"LOOK FOR YOUR HEADERS HERE\",\"created_at\":\"2011-11-07T18:34:21+00:00\",\"body\":\"\",\"params\":\"{}\"}],\"content\":\"this is list of products\",\"description\":null,\"status\":null,\"active\":true}}"

  The important bit here is 'requests' array. This is history of requests for that double (in chronological order). Each element contains the following data (keys):
  
  - __body__ - request payload
  - __params__ - request parameters
  - __created_at__ - request timestamp
  - __rack_env__ - raw request dump (key value pairs). Including request headers

* `DELETE '/doubles/all'`
  Deletes all doubles.

### Redirects

It is sometimes desirable to only double certain calls while letting others through to the 'real' services. Meet Redirects. Kind of "rewrite rules" for requests that didn't match any double. Here is the rest API for managing redirects:

* `POST '/redirects', { pattern: pattern, to: uri }` Creates redirect with the following parameters:

  - __pattern__ - regex (perl5 style) tested against request fullpath. Mandatory
  - __to__ - url base e.g., `https://myserver:8787/api`. Mandatory

  Example (using ruby RestClient):

    RestClient.post 'http://localhost:4578/redirects', { pattern: '^/auth', to: 'https://myserver.com/api' }

  Now request (any verb) to http://localhost:4578/auth/services/1 will get redirected to https://myserver.com/api/auth/services/1. Provided of course there is no double matched for that fullpath and verb.
  Much like rewrite rules, redirects are evaluated in order (of creation). In UI you can manually rearrange the order.

### Storage

By default when you start rest-assured it creates (unless already exists) sqlite database and stores it into file in the current directory. This is good for using it for development - when you want doubles/redirects to persist across restarts - but may not be so desirable for using with tests, where you want each test run to start from blank slate. For that reason, you can specify `--database :memory:` so that database is kept in memory.

### Logging

It is sometimes useful to see what requests rest-assured is being hit. Either to explore what requests your app is making or to check that test setup is right and doubles indeed get returned. By default, when started, rest-assured creates log file in the current directory. This is configurable with `--logfile` option.

## TODO

* Implement expectations
* Support headers (extends previous point)
* Ruby client library
* Support verbs in UI (at the moment it is always GET)
* Don't allow to double internal routes. Just in case

## Author

[Artem Avetisyan](https://github.com/artemave)
