RSpec API Requests
==================

RSpecApi::Requests lets you make requests to web APIs and verify their expectations:

    params = {host: 'http://api.example.com', route: '/concerts', attributes: {where: {type: :string}}

    describe 'GET /concerts', rspec_api_params: params do
      respond_with :ok
    end

More documentation and examples about RSpecApi are available at [http://rspec-api.github.io](http://rspec-api.github.io)

[![Build Status](https://travis-ci.org/rspec-api/rspec-api-requests.png?branch=master)](https://travis-ci.org/rspec-api/rspec-api-requests)
[![Code Climate](https://codeclimate.com/github/rspec-api/rspec-api-requests.png)](https://codeclimate.com/github/rspec-api/rspec-api-requests)
[![Coverage Status](https://coveralls.io/repos/rspec-api/rspec-api-requests/badge.png)](https://coveralls.io/r/rspec-api/rspec-api-requests)
[![Dependency Status](https://gemnasium.com/rspec-api/rspec-api-requests.png)](https://gemnasium.com/rspec-api/rspec-api-requests)


Basic example
-------------

    # 1. Specify how to connect to the API and what to expect:
    gists_params = {
      host: 'https://api.github.com',
      action: 'get',
      authorize_with: {token: YOUR-GITHUB-TOKEN-HERE},
      route: '/gists',
      collection: true,
      attributes: {url: {type: {string: :url}}},
      extra_requests: [{
        expect: {filter: {by: :updated_at, compare_with: :>=, value: '2012-10-10T00:00:00Z'}},
        params: {since: '2012-10-10T00:00:00Z'}
      }]
    }

    # 2. Use `respond_to` to send the request and verify the expectations
    describe 'GitHub Gists', rspec_api_params: gists_params do
      respond_with :ok
    end

Running the example above returns the following successful output:

    Examples from GitHub API
      GitHub Gists
        GET /gists with {:since=>"2012-10-10T00:00:00Z"}
          responds with a body that
            should be a collection
            should have attributes {:url=>{:type=>{:string=>:url}}}
            should be filtered by updated_at>=2012-10-10T00:00:00Z
          responds with a status code that
            should be 200
        GET /gists
          responds with a body that
            should have attributes {:url=>{:type=>{:string=>:url}}}
            should be a collection
          responds with a status code that
            should be 200

    Finished in 0.01056 seconds
    7 examples, 0 failures

Note that, in order run the example, above, you need to replace
`YOUR-GITHUB-TOKEN-HERE` with your [GitHub Personal Access Token](https://github.com/settings/applications).


Available request options
=========================

RSpecApi::Requests makes available one method `respond_to`, which sends the
request to the API and verify the expectations specified using RSpec metadata
`rspec_api_params` in the surrounding `describe` block, as shown above.
The following are the valid request options for `rspec_api_params`.

:host and :adapter (*either one or the other is required*)
----------------------------------------------------------

Respectively the URL where the API is hosted and the adapter to connect to it.
By default, RSpecApi::Requests uses `Net::HTTP`, e.g:

    host: 'http://example.com' # => connect via Net::HTTP

This behavior can be overridden specifying a different adapter:

    adapter: [:rack, app] # => connect via Rack::Test to a local Rack app

Therefore, RSpecApi::Requests can be used both to send requests to **remote**
and to **local** web API, making API development easier.

:route (*required*)
-------------------

The API route to access a resource, e.g.:

    host: 'http://example.com', route: '/concerts'
    # => connect to 'http://example.com/concerts'

:action (*required*)
--------------------

The HTTP method to access a resource, e.g.:

    action: :delete, route: '/concerts'
    # => sends 'DELETE /concerts'

:authorize_with (*optional*)
----------------------------

The HTTP authentication payload to send with the request, e.g.:

    authorize_with: {token: 'foo'}
    # => sends [:token, 'foo'] as the HTTP authentication


Available expectations
======================

The following are the valid expectations for `rspec_api_params`.

:collection (*optional*)
------------------------

Whether the response body will include a *single* JSON object
(`collection: false`) or a *collection* of objects (`collection: true`), e.g.:

    action: :get, route: '/concerts', collection: true
    # => expect `GET /concerts' to return a collection

    action: :get, route: '/concerts/1', collection: false
    # => expect `GET /concerts/1' to return an object

:attributes (*optional*)
------------------------

Which attributes the JSON object or collection in the response body will contain, e.g.:

    action: :get, route: '/concerts/1', attributes: {url: {type: {string: :url}}}
    # => expect `GET /concerts/1' to return an object with a 'url' field
    #    that should contain a URL-formatted string

Extra requests
==============

The last option of `rspec_api_params` allows to send multiple API requests:

:extra_requests (*optional*)
----------------------------

Which extra requests should be sent and what to expect from them, e.g.:

    action: :get, route: '/concerts', extra_requests: [{
      expect: {filter: {by: :created_at, compare_with: :>=, value: '2012-10-10T00:00:00Z'}},
      params: {since: '2012-10-10T00:00:00Z'}
    }]
    # => expect `GET /concerts/1?since=2012-10-10T00:00:00Z' to only return
    #    concerts created after October 10th, 2012.


How to install
==============

To install on your system, run `gem install rspec-api-requests`.
To use inside a bundled Ruby project, add this line to the Gemfile:

    gem 'rspec-api-requests', '~> 0.7.0'

The rspec-api-requests gem follows [Semantic Versioning](http://semver.org).
Any new release that is fully backward-compatible bumps the *patch* version (0.0.x).
Any new version that breaks compatibility bumps the *minor* version (0.x.0)

Indicating the full version in your Gemfile (*major*.*minor*.*patch*) guarantees
that your project won’t occur in any error when you `bundle update` and a new
version of RSpecApi::Requests is released.


How to contribute
=================

Don’t hesitate to send me code comments, issues or pull requests through GitHub!

All feedback is appreciated. Thanks :)