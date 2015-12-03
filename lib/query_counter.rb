require 'active_support'
require_relative './active_record/query_counter'

module QueryCounter
  extend ActiveSupport::Autoload

  autoload :MysqlHook

  if defined? Rails::Railtie
    require 'query_counter/railtie'
  elsif defined? Rails::Initializer
    raise "QueryCounter 1.0 is not compatible with Rails 2.3 or older"
  end
end


