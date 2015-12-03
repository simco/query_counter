module QueryCounter
  module MysqlHook

    def execute(sql, name = nil)
      result = super

      ActiveRecord::QueryCounter.instance.send(:increment, sql) if ActiveRecord::QueryCounter.instance.started?

      result
    end

  end
end
