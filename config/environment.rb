require 'sqlite3'


DB = {:conn => SQLite3::Database.new("db/songs.db")}
#Creating the database 


DB[:conn].execute("DROP TABLE IF EXISTS songs")
#dropping the songs table to avoid an error

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL
#Creating the songs table

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true

#Lastly, we use the #results_as_hash method, available to use from the SQLite3-Ruby gem. T
#This method says: when a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column names as keys.




