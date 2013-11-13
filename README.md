RSpec API Requests
==================

Remember how RSpecApi::Expectations let you write something like this?

    # 1. Make a request to the GitHub API:

    require 'faraday'
    conn = Faraday.new 'https://api.github.com/' do |c|
      c.use Faraday::Adapter::NetHttp
    end
    conn.headers[:user_agent] = 'RSpec API'
    conn.authorization :token, ENV['RSPEC_API_GITHUB_TOKEN']
    response = conn.get '/repositories'

    # 2. Expect the response to be successful and to return a JSON collection,
    #    where each object has an ID key/value (number), a name key/value
    #    (string) and a url key/value (string in URL format)

    require 'rspec-api/requests'

    describe 'List all public repositories', rspec_api: true do
      expect_response response, status: :ok, type: :json, collection: true,
        attributes: {id: {type: :number}, name: {type: :string},
                     url: {type: {string: :url}}}


Well, it would make sense for that request and that expectation to go together,
not to be separate. RSpecApi::Requests let you do that, and write:

    describe 'List all public repositories', rspec_api: true do
      get '/repositories',
        host: 'https://api.github.com/',
        authorize_with: ENV['RSPEC_API_GITHUB_TOKEN'],
        attributes: {id: {type: :number}, name: {type: :string}, url: {type: {string: :url}}} do
        respond_with :ok
      end
    end

or even this:

    describe 'List all public repositories', rspec_api: true do
      host 'https://api.github.com/'
      authorize_with: {token: ENV['RSPEC_API_GITHUB_TOKEN']}

      has_attribute :id, {type: :number}
      has_attribute :name, {type: :string}, url: {type: {string: :url}}}

      get '/repositories' do
        respond_with :ok
      end
    end

And all of these are equivalent. But this syntax hides the real requests, making
you focus more on the expectations, and also allows you to make many requests
with the same expectations on the attributes, which is a best practice of
an API. For instance if you get ONE repo, ALL the repos or FILTERED repos,
you should still get a result with those attributes:


      get '/repositories?since=1234' do
        respond_with :ok
      end

      get '/repos/:owner/:repo' do
        respond_with :ok, owner: 'rspec-api', repo: 'rspec-api-requests'
      end

      get '/repos/:owner/:repo' do
        respond_with :not_found, owner: 'not-an-owner', repo: 'not-a-repo'
      end

So in short, rspec-api-requests adds methods to RSpec's ExampleGroups tagged
as :rspec_api:

* the most important methods are the actions: get, put, post, patch,
delete -- they make the request to the API

* inside those methods, `respond_with`, which checks that the expectations on
that endpoint are met. By default, we expect JSON and we indicate the status.
Also, `respond_with` gets the values to replace the placeholders in the route

* more expectations on the attributes can be set with `has_attribute`

* configuration about the requests can be set with `host` and `authorize_with`