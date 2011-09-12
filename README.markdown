# REST doubles

## Overview

A tool for stubbing/mocking external http based services that app under test is talking to. This is useful for blackbox testing or in cases where it is not possible to access application objects directly from test code.
There are three main use cases:

* stubbing out external data sources with predefined data, so that test code has known data to assert against
* setting expectations on messages to external services (currently not yet implemented)
* mimic different responses from external services during development. For that purpose there is web UI

## Usage

You are going to need ruby >= 1.8.7. Install gem and run:

    sudo gem install rest-doubles # omit sudo if using rvm
    rest-doubles &

Or clone from github and run:

    git clone git@github.com:BBC/rest-doubles.git
    ./rest-doubles/bin/rest-doubles &

This starts an instance of rest-doubles on port 4578 (changable with --port option) and creates rest-doubles.db (changable with --database option) in the current directory. You can now access it via rest or web interfaces on http://localhost:4578

### Doubles

Double is a stub/mock of a particular external call. There is the following rest API for setting up doubles:

* `POST '/doubles', { request_fullpath: path, content: content, method: method }`
  Creates double with the following parameters:

  - __request_fullpath__ - e.g., `/some/api/object`, or with parameters in query string (useful for doubling GETs) - `/some/other/api/object?a=2&b=c`. Mandatory.
  - __content__ - whatever you want this double to respond with. Mandatory.
  - __method__ - one of http the following http verbs: GET, POST, PUT, DELETE. Optional. GET is default.

  Example (using ruby RestClient):
  
    RestClient.post 'http://localhost:4578:/doubles', { request_fullpath: '/api/v2/products?type=fresh', method: 'GET', content: 'this is list of products' }

  Now GETting http://localhost:4578/api/v2/products?type=fresh (in browser for instance) should return "this is list of products".

  If there is more than one double for the same request\_fullpath and method, the last created one gets served. In UI you can manually control which double is 'active' (gets served).

* `DELETE '/doubles/all'`
  Deletes all doubles.

### Redirects

It is sometimes desirable to only double certain calls whilst letting others through to the 'real' services. Meet Redirects. Kind of "rewrite rules" for requests that didn't match any double. Here is the resp API for managing redirects:

* `POST '/redirects', { pattern: pattern, to: uri }` Creates redirect with the following parameters:

  - __pattern__ - regex (perl5 style) tested against request fullpath. Mandatory
  - __to__ - url base e.g., `https://myserver:8787/api`. Mandatory

  Example (using ruby RestClient):

    RestClient.post 'http://localhost:4578/redirects', { pattern: '^/auth', to: 'https://myserver.com/api' }

  Now request (any method) to http://localhost:4578/auth/something/useful will get redirected to https://myserver.com/api/something/useful. Provided of course there is no double matched for that fullpath and method.
  Much like rewrite rules, redirects are evaluated in order (of creation). In UI you can manually rearrange the order.

### Storage

By default when you start rest-doubles it creates (unless already exists) sqlite database and stores it into file in the current directory. This is good for using it for development - when you want doubles/redirects to persist across restarts - but may not be so desirable for using with tests, where you want each test run to start from blank slate. For that reason, you can specify `--database :memory:` so that database is kept in memory.

## TODO

* Implement expectations
* Support headers (extends previous point)
* Ruby client library

## Author

[Artem Avetisyan](https://github.com/artemave)
