# frozen_string_literal: true

Discourse::Application.routes.append do
  scope module: 'discourse_events_integration', constraints: AdminConstraint.new do
    get '/admin/events-integration' => 'admin#index'
    get '/admin/events-integration/provider' => 'provider#index'
    put '/admin/events-integration/provider/new' => 'provider#create'
    put '/admin/events-integration/provider/:id' => 'provider#update'
    get '/admin/events-integration/provider/:id/authorize' => 'provider#authorize'
    get '/admin/events-integration/provider/:id/redirect' => 'provider#redirect'
    delete '/admin/events-integration/provider/:id' => 'provider#destroy'
    get '/admin/events-integration/source' => 'source#index'
    put '/admin/events-integration/source/new' => 'source#create'
    put '/admin/events-integration/source/:id' => 'source#update'
    post '/admin/events-integration/source/:id' => 'source#import'
    delete '/admin/events-integration/source/:id' => 'source#destroy'
    get '/admin/events-integration/connection' => 'connection#index'
    put '/admin/events-integration/connection/new' => 'connection#create'
    put '/admin/events-integration/connection/:id' => 'connection#update'
    post '/admin/events-integration/connection/:id' => 'connection#sync'
    delete '/admin/events-integration/connection/:id' => 'connection#destroy'
    get '/admin/events-integration/event' => 'event#index'
    delete '/admin/events-integration/event' => 'event#destroy'
    get '/admin/events-integration/log' => 'log#index'
  end
end
