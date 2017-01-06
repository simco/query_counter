module ActiveRecord
  class QueryCounter
    include Singleton

    COUNT_QUERY_TYPE = %w(SELECT UPDATE INSERT DELETE).freeze

    def initialize
      @start_query_counter = false
    end

    def start
      @start_query_counter = true
    end

    def stop
      @start_query_counter = false
    end

    def started?
      # @start_query_counter || false
      @start_query_counter
    end

    def restart
      reset
      start
    end

    def reset
      (@query_counter = {}) == {} 
    end

    def count sql_operation = nil
      sql_operation = sql_operation.to_s.upcase unless sql_operation.nil?

      (@query_counter || {}).sum { |key, value| (COUNT_QUERY_TYPE.include?(key) && sql_operation.nil?) || sql_operation == key ? value : 0 }
    end

    def within
      restart
      yield
      stop

      nil # force nil to be returned
    end

    private
    def increment sql
      if started?
        sql_operation = sql.split[0].to_s.upcase
        ((@query_counter ||= {})[sql_operation] ||= 0)
        @query_counter[sql_operation] = @query_counter[sql_operation] + 1
      end
    end

  end
end

