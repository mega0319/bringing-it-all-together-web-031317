require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id:nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(array)
    name = array[1]
    breed = array[2]
    id = array[0]
    new_dog = self.new(name:name, breed:breed, id:id)
    new_dog
  end

  def save
    if self.id
      self.update
    else
    sql = <<-SQL
    INSERT INTO dogs(
      name, breed
    )
    VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid()FROM dogs")[0][0]
  end
  self
end

  def self.create(hash)
    new_instance = self.new(hash)
    new_instance.save
    new_instance
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    SQL
    result = DB[:conn].execute(sql, id)
    self.new_from_db(result[0])
  end


  def self.find_by_name(dog)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ?
    SQL
    result = DB[:conn].execute(sql, dog)
    self.new_from_db(result[0])
  end

  def update
    sql = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(hash)
    dogggs = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", hash[:name], hash[:breed])
    if dogggs.empty?
      self.create(hash)
    else
      self.new_from_db(dogggs[0])
    end
  end







end
