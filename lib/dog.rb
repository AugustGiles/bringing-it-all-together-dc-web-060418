require 'pry'
class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.breed)

    @id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]

    self
  end

  def self.create (name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_by_id(num)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?;
    SQL

    dog = DB[:conn].execute(sql, num)[0]
    self.new(name: dog[1], breed: dog[2], id: dog[0])
  end

  def self.find_or_create_by

  end

  def self.new_from_db(row)
    self.new(name: row[1], breed: row[2], id: row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?;
    SQL

    dog = DB[:conn].execute(sql, name)[0]

    self.new(name: dog[1], breed: dog[2], id: dog[0])
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?;
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    instance = DB[:conn].execute(sql, name, breed)
    if !instance.empty?
      found_instance = instance[0]
      self.new(name: found_instance[1], breed: found_instance[2], id: found_instance[0])
    else
      self.create(name: name, breed: breed)
    end
    #binding.pry
  end

end
