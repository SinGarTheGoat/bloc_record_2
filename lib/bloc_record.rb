module BlocRecord
  def self.connect_to(filename, database = :sqlite3)
    @database_filename = filename
    @database_whoop = database
  end

  def self.database_whoop
    @database_whoop
  end

  def self.database_filename
    @database_filename
  end
end
