require 'singleton'
require 'sqlite3'
require_relative '../questions'

class QuestionLike
  
  attr_accessor :user_id, :question_id
  
  def self.all 
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
    results.map { |result| QuestionLike.new(result) }
  end
  
  def initialize(options = {})
    @user_id, @question_id = options.values_at('user_id', 'question_id') 
  end
  
  # Return array of likers for a particular question
  def self.likers_for_question_id(question_id)
    query_res = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
    SELECT *
    FROM questions q
    JOIN question_likes ql
    ON q.id = ql.question_id
    WHERE ql.question_id = :question_id
    SQL
  
    query_res.map { |row| User.new(row) }
  end
  
  # Return number of likes for a question
  def self.num_likes_for_question_id(question_id)
    QuestionsDatabase.get_first_value(<<-SQL, question_id: question_id)
    SELECT COUNT(*)
    FROM question_likes
    WHERE question_id = :question_id
    GROUP BY question_id
    SQL
  end
  
  # Return an array of questions that a user has liked
  def self.liked_questions_for_user_id(user_id)
    query_res = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
    SELECT *
    FROM questions q
    JOIN question_likes ql
    ON q.id = ql.question_id
    WHERE ql.user_id = :user_id
    SQL
  
    query_res.map { |row| Question.new(row) }
  end
  
  def self.most_liked_questions(n)
    query = <<-SQL
      SELECT *
      FROM questions q
      JOIN question_likes ql
      ON ql.question_id = q.id
      GROUP BY ql.question_id
      ORDER BY COUNT(user_id)
      LIMIT ?
    SQL
    
    query_res = QuestionsDatabase.instance.execute(query, n)
    query_res.map { |row| Question.new(row) }
  end
end
  