require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
  #attr_reader

  def initialize(id=nil, name, grade)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students (
        id INTEGER PRIMARY KEY,
        name TEXT
        grade INTEGER
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
       self.update
     else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?,?);
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    student = Student.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row_array)

    new_student = self.new(row_array[0],row_array[1],row_array[2])
    #binding.pry
    # new_student.id = row_array[0]
    # new_student.name = row_array[1]
    # new_student.grade = row_array[2]

  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM students
      WHERE students.name = name
      LIMIT 1
    SQL

    DB[:conn].execute(sql).map do |student|
      self.new_from_db(student)
    end.first
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end
