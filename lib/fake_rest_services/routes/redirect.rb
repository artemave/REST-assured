module FakeRestServices
  module RedirectRoutes
    def self.included(router)
      router.post '/redirects' do
        Redirect.create(pattern: params['pattern'], to: params['to'])
      end
    end
  end
end
