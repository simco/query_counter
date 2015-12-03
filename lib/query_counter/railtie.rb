module QueryCounter

  class Railtie < Rails::Railtie
    initializer 'query_counter.insert_into_mysql2_adapter' do
      ActiveSupport.on_load :active_record do
#       ActiveRecord::ConnectionAdapters::DatabaseStatements.send(:include, QueryCounter::MysqlHook)
        ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(:include, QueryCounter::MysqlHook)
      end
    end
  end

end
