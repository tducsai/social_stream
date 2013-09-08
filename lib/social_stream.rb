if Rails.env == 'development'
  begin
    # pry
    require 'pry-rails'
    # Rails panel
    require 'meta_request'
  rescue LoadError => e
  end
end

module SocialStream
  Components = %w{ base documents events linkser presence ostatus oauth2_server }

  class Engine < ::Rails::Engine #:nodoc:
    config.app_generators.base       'social_stream:base'
    config.app_generators.documents  'social_stream:documents'
    config.app_generators.events     'social_stream:events'
    config.app_generators.linkser    'social_stream:linkser'
    config.app_generators.chat       'social_stream:presence'
    config.app_generators.federation 'social_stream:ostatus'
    config.app_generators.oauth2_server 'social_stream:oauth2_server'
  end
end

SocialStream::Components.each do |component|
  require "social_stream-#{ component }" # require "social_stream-base"
end
