require 'social_stream/base/thinking-sphinx'

ThinkingSphinx::ActiveRecord::Interpreter.send :include, SocialStream::Base::ThinkingSphinx::ActiveRecord::Interpreter
