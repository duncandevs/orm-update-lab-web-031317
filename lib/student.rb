require_relative "../config/environment.rb"
# Student
#   attributes
#     has a name and a grade (FAILED - 1)
#     has an id that defaults to `nil` on initialization (FAILED - 2)
#   #create_table
#     creates the students table in the database (FAILED - 3)
#   #drop_table
#     drops the students table from the database (FAILED - 4)
#   #save
#     saves an instance of the Student class to the database and then sets the given students `id` attribute (FAILED - 5)
#     updates a record if called on an object that is already persisted (FAILED - 6)
#   #create
#     creates a student object with name and grade attributes (FAILED - 7)
#   #new_from_db
#     creates an instance with corresponding attribute values (FAILED - 8)
#   #find_by_name
#     returns an instance of student that matches the name from the DB (FAILED - 9)
#   #update
# Remember, you can access your database connection anywhere in this class
#  with DB[:conn] Remember that DB is a hash {conn: ...}
class Student
    attr_accessor :name, :grade , :id

    def initialize(id=nil, name, grade)
      @name = name
      @grade = grade
      @id = id
    end

    def self.create_table
      sql = <<-SQL
      CREATE TABLE students (
        name text,
        grade integer,
        id INTEGER PRIMARY KEY
      );
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = "DROP TABLE students"
      DB[:conn].execute(sql)
    end

    def save
      #save the instance to the DB
      #check if record exists by checking unique id not set to nil
      if self.id
        self.update
      else
        sql = "INSERT INTO students (name,grade) VALUES (?,?)"
        DB[:conn].execute(sql, self.name, self.grade)
        # return the id of the last entry
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
      end
    end

    def update
      #update is running an update sql query on the objects instance variables
      sql = <<-SQL
              UPDATE students SET name = ? , grade = ?
              WHERE id = ?
            SQL
      DB[:conn].execute(sql,self.name, self.grade, self.id)
      #will break if the record does not exists obvious since you can only update existing record
    end

    def self.create(name,grade)
      #creates a student object then saves it to the DB
      Student.new(name,grade).save
    end

    def self.new_from_db(entry)
      #creates an instance with corresponding attribute values
      #reverse of create method, gets entry from DB and converts to object
      #entry = [1, "Pat", 12] note that this method assumes a select query has alredy been run
      new_student = Student.new(entry[0],entry[1],entry[2])
      new_student
    end

    def self.find_by_name(name)
      #returns the instance that matches the db entry
      sql = <<-sql
            SELECT * FROM students WHERE name = ?
            sql
      new_from_db(DB[:conn].execute(sql,name)[0])
    end
end
