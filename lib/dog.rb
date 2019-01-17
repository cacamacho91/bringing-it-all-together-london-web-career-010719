
class Dog
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      bred TEXT
    )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ? breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    end
    self
  end

  def self.create(name:, breed:)
    new_dog = self.new(name: name, breed: breed)
    new_dog.save
  end

  def self.find_by_id(id)
    id, name, breed = DB[:conn].execute("SELECT * FROM dogs WHERE id=#{id}").first
    self.new(id: id, name: name, breed: breed)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    if !dog.empty?
      id, name, breed = dog.first
      dog = Dog.new(id: id, name: name, breed: breed)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    id, name, breed = row
    Dog.new(id: id, name: name, breed: breed)
  end

  def self.find_by_name(name)
    id, name, breed = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
    Dog.new(id: id,  name: name, breed: breed)
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id)
  end


end
