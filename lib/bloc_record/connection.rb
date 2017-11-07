require 'sqlite3'
require 'pg'

module Connection
  def connection
    if BlocRecord.database_whoop == 'sqlite3'
        @connection ||= SQLite3::Database.new(BlocRecord.database_filename)
    elsif BlocRecord.database_whoop == 'pg'
        @connection ||= PG::Connection.open(BlocRecord.database_filename)
    else
      puts "whoops"
    end
    puts   @connection
      @connection
  end
end
