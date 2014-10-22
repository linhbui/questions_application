require 'singleton'
require 'sqlite3'
require_relative '../questions'

class User
  
  attr_accessor :fname, :lname 
  attr_reader :id
  # execute SELECT, result in an 'Array' of 'Hash'es, each represent
  # a single row
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM users')
    results.map { |result| User.new(result) }
  end
  
  def initialize(options = {})
    @id, @fname, @lname = options['id'], options['fname'], options['lname']
  end
  
  # execute an INSERT; the '?' gets replaced with the value name. The
  # '?' lets us separate SQL commands from data, improving
  # readability, and also safety (lookup SQL injection attack on
  # wikipedia).
  # When object already existed, use UPDATE 
  def save
    params = [self.fname, self.lname]
    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, *params)
        INSERT INTO
          users (fname, lname)
        VALUES
          (?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, *params, self.id)
      UPDATE users
      SET
        fname     = ?,
        lname     = ?
      WHERE id = ?
      SQL
    end
  end

  # return object representing the row with the id
  def self.find_by_id(id)
    query = <<-SQL
      SELECT *
      FROM users
      WHERE users.id = ?
    SQL
    
    User.new(QuestionsDatabase.instance.execute(query, id).first)
  end
  
  def self.find_by_name(fname, lname)
    query = <<-SQL
      SELECT *
      FROM users
      WHERE users.fname = ? AND users.lname = ?
    SQL
    
    User.new(QuestionsDatabase.instance.execute(query, fname, lname).first)
  end
  
  # Return an array of questions this user has asked
  def authored_questions
    Question.find_by_author_id(self.id)
  end
  
  # Return an array of replies this user has asked
  def authored_replies
    Reply.find_by_author_id(self.id)
  end
  
  # Return an array of questions the user followed    
  def followed_questions
    QuestionFollower.followed_questions_for_user_id(self.id)
  end
  
  # Return an array of questions the user liked 
  def liked_questions
    QuestionLike.liked_questions_for_user_id(self.id)
  end
  
  # Return the average number of likes for a user's questions
  def average_karma
    query = <<-SQL
      SELECT AVG(all_likes.likes)
      FROM 
        (SELECT COUNT(*) AS likes
         FROM question_likes ql
         JOIN questions q
         ON q.id = ql.question_id
         WHERE q.author_id = ?
         GROUP BY q.id
         ) AS all_likes
    SQL
    
    QuestionsDatabase.instance.execute(query, self.id)
  end
end
