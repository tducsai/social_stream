class SocialStream::InstallGenerator < Rails::Generators::Base #:nodoc:
  hook_for :base
  hook_for :documents
  hook_for :events
  hook_for :linkser
  hook_for :chat
  hook_for :federation
  hook_for :oauth2_server
end
