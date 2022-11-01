class Dog

  attr_accessor :name, :breed, :id 

  ## initialize a Dog class/has an id that defaults to `nil` on initialization
  def initialize(name:, breed:, id:nil)
    @id = id
    @name = name
    @breed = breed
  end

  ## create table
  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed INTEGER
      )
    SQL
    DB[:conn].execute(sql)
  end

  ##drops the dog table
  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  ##save, method return instance of dog class
  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql,self.name,self.breed)
    
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  ##.create new row, return new instance of the Dog
  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
  end

  ##.new_from_db , return an array rep a dogs data
  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])  
  end

  ##all 
  def self.all
    sql = <<-SQL
      SELECT * FROM dogs
    SQL
    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
      end
  end

  ##find_by_name
  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end 

  ##find(id) takes an ID and should return a single Dog instance for corresponding record in the dogs
  def self.find(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
    end.first
  end

end
