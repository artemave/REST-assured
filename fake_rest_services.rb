#!/usr/bin/env ruby

require 'bundler/setup'
require 'sinatra'
require 'sinatra/activerecord'

ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: File.expand_path('../production.db', __FILE__)
)

require 'models/fixture'

#get '/dsp/assets/search' do
  #team = lookup_team_name params['concept']

  #case params['story-type']
  #when 'news-story'
    ## footballTeams.serviceCalls.teamStories[1]
    ## https://api.live.bbc.co.uk/dsp/assets/search?concept=http://www.bbc.co.uk/things/c4285a9a-9865-2343-af3a-8653f7b70734%23id&format=story&story-type=news-story&tagging-type=about&limit=11
    #File.read("#{responses_path}/#{team}/team_stories.json")
    ##FakeResponse.lookup('teamStories[1]', concept: params['concept'])
  #when 'feature'
    ## footballTeams.serviceCalls.teamCommentAnalysis[1]
    ## https://api.live.bbc.co.uk/dsp/assets/search?concept=http://www.bbc.co.uk/things/c4285a9a-9865-2343-af3a-8653f7b70734%23id&format=blog&story-type=blog-post&format=story&story-type=feature&tagging-type=about&limit=20
    #File.read("#{responses_path}/#{team}/team_comment_analysis.json")
  #else
    #puts "wrong call to /dsp/assets/search: params: #{params.inspect}"
  #end
#end

#get %r{/sportsdata/statsapi/football/teamstats/team/(\d+)/clubstats} do |team_id|
  #team = lookup_team_name team_id

  ## footballTeams.serviceCalls.clubStats[1]
  ## https://api.int.bbc.co.uk/sportsdata/statsapi/football/teamstats/team/138824012/clubstats
  #File.read("#{responses_path}/#{team}/club_stats.json")
#end

#get %r{/sportsdata/statsapi/football/table/competition/(\d*)} do |competition_id|
  #File.read("#{responses_path}/competitions/#{competition_id}.json")
#end

#get /.*/ do
  #redirect "#{env['PATH_INFO'] =~ /esp-service/ ? 'http://open' : 'https://api' }.int.bbc.co.uk#{env['REQUEST_URI']}"
#end

post '/fixtures' do
  Fixture.create(url: params['url'], content: params['content'])
end

get /.*/ do
  Fixture.where(url: request.fullpath).last.try(:content) or redirect real_api_url(request)
end

def real_api_url(request)
  "#{request.path_info =~ /esp-service/ ? 'http://open' : 'https://api' }.int.bbc.co.uk#{request.fullpath}"
end

