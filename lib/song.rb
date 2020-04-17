require_relative "../config/environment.rb"
require 'active_support/inflector'

class Song


  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  #This method takes the name of the class, referenced by the self keyword, turns it into a string with #to_s, downcases (or "un-capitalizes") that string and then "pluralizes" it, or makes it plural.
  
  #The #pluralize method is provided to us by the active_support/inflector code library, required at the top of lib/song.rb.
  
  def self.column_names
    DB[:conn].results_as_hash = true
    
    #Need to query the table for names of its columns 
    sql = "pragma table_info('#{table_name}')"
    
    
    #This line of code that utilizes PRAGMA will return to us (thanks to our handy #results_as_hash method) an array of hashes describing the table itself.  Each hash will contain information about one column. 
    
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    #We iterate over the resulting array of hashes to collect just the name of each column. We call #compact on that just to be safe and get rid of any nil values that may end up in our collection.
    
    column_names.compact
  end
  
  #Now that we have a method that returns us an array of column names, ["id", "name", "album"], we can use this collection to create the attr_accessors of our Song class.

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  #Here, we define our method to take in an argument of options, which defaults to an empty hash. We expect #new to be called with a hash, so when we refer to options inside the #initialize method, we expect to be operating on a hash.

  #We iterate over the options hash and use our fancy metaprogramming #send method to interpolate the name of each hash key as a method that we set equal to that key's value. As long as each property has a corresponding attr_accessor, this #initialize method will work.

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  #Luckily for us, we already have a method to give us the table name associated to any given class: <class name>.table_name.

#Recall, however, that the conventional #save is an instance method. So, inside a #save method, self will refer to the instance of the class, not the class itself. In order to use a class method inside an instance method, we need to do the following:

  def table_name_for_insert
    self.class.table_name
  end
  
  #In fact, we already know how to programmatically invoke a method, without knowing the exact name of the method, using the #send method.

#Let's iterate over the column names stored in #column_names and use the #send method with each individual column name to invoke the method by that same name and capture the return value:

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    #We need comma separated values for our SQL statement. Let's join this array into a string:
    values.join(", ")
  end
  
  #when we save our Ruby object, we should not include the id column name or insert a value for the id column. Therefore, we need to remove "id" from the array of column names returned from the method call above:
  

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    #returns ["name", "album"]
    #Notice that the column names in the statement are comma separated. Our column names returned by the code above are in an array. Let's turn them into a comma separated list, contained in a string.
    #Returns "name, album"
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end



