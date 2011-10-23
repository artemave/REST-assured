# fix leaking db connections https://github.com/rails/rails/commit/ea341b8e043160a7ddaba9e6b2bb6044f73c31a8
# TODO remove with the next ActiveRecord update as this patch will be there
module ActiveRecord
  class ConnectionAdapters::ConnectionPool
    def current_connection_id #:nodoc:
      ActiveRecord::Base.connection_id ||= Thread.current.object_id
    end
  end

  class Base::ConnectionSpecification
    class << self
      def connection_id
        Thread.current['ActiveRecord::Base.connection_id']
      end

      def connection_id=(connection_id)
        Thread.current['ActiveRecord::Base.connection_id'] = connection_id
      end
    end
  end

  class QueryCache
    class BodyProxy
      def initialize(original_cache_value, target, connection_id)
        @original_cache_value = original_cache_value
        @target               = target
        @connection_id        = connection_id
      end

      def close
        @target.close if @target.respond_to?(:close)
      ensure
        ActiveRecord::Base.connection_id = @connection_id
        ActiveRecord::Base.connection.clear_query_cache
        unless @original_cache_value
          ActiveRecord::Base.connection.disable_query_cache!
        end
      end
    end

    def call(env)
      old = ActiveRecord::Base.connection.query_cache_enabled
      ActiveRecord::Base.connection.enable_query_cache!

      status, headers, body = @app.call(env)
      [status, headers, BodyProxy.new(old, body, ActiveRecord::Base.connection_id)]
    rescue Exception => e
      ActiveRecord::Base.connection.clear_query_cache
      unless old
        ActiveRecord::Base.connection.disable_query_cache!
      end
      raise e
    end
  end
end
