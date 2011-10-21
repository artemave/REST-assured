# fixes dreaded db locked problem
# see details here http://stackoverflow.com/questions/78801/sqlite3busyexception/6099601#6099601
module ActiveRecord
  module ConnectionAdapters #:nodoc:
    class SQLiteAdapter
      def begin_db_transaction #:nodoc:
        @connection.transaction(:immediate)
      end
    end
  end
end
