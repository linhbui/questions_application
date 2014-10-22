require 'singleton'
require 'sqlite3'
require_relative '../questions'

class QuestionFollower
  
  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM question_followers')
    results.map { |result| QuestionFollower.new(result) }
  end

  attr_accessor :user_id, :question_id
  
  def initialize(options = {})
    @user_id, @question_id = options.values_at('user_id', 'question_id') 
  end

  # Return an array of all users who follow a question
  def self.followers_for_question_id(question_id)
    query_res = QuestionsDatabase.instance.execute(<<-SQL, question_id: question_id)
      SELECT * 
      FROM users
      JOIN question_followers 
      ON users.id = question_followers.user_id
      WHERE question_followers.question_id = :question_id
    SQL
    
    query_res.map { |row| User.new(row) }
  end
  
  # Return an array of all questions followed by a user
  def self.followed_questions_for_user_id(user_id)
    query_res = QuestionsDatabase.instance.execute(<<-SQL, user_id: user_id)
      SELECT *
      FROM questions
      JOIN question_followers
      ON questions.id = question_followers.question_id
      WHERE question_followers.user_id = :user_id
    SQL
    
    query_res.map { |row| Question.new(row) }
  end
  
  # Return array of most followed questions on database
  def self.most_followed_questions(n)
    query = <<-SQL
      SELECT *
      FROM questions q
      JOIN question_followers qf
      ON qf.question_id = q.id
      GROUP BY qf.question_id
      ORDER BY COUNT(user_id)
      LIMIT ?
    SQL
    
    query_res = QuestionsDatabase.instance.execute(query, n)
    query_res.map { |row| Question.new(row) }
  end
  
end
