require 'singleton'
require 'sqlite3'
require_relative '../questions'

class Question

  def self.all
    results = QuestionsDatabase.instance.execute('SELECT * FROM questions')
    results.map { |result| Question.new(result) }
  end
  
  attr_accessor :title, :body, :author_id
  attr_reader :id

  def initialize(options = {})
    @id, @title, @body, @author_id = 
      options.values_at('id', 'title', 'body', 'author_id')
  end
  
  def save
    params = [self.title, self.body, self.author_id]
    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
        questions (title, body, author_id)
      VALUES
        (?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, *params, self.id)
      UPDATE questions
      SET
        title     = ?,
        body      = ?,
        author_id = ?
      WHERE id = ?
      SQL
    end
  end
  
  def self.find_by_id(q_id)
    query = <<-SQL
      SELECT *
      FROM questions
      WHERE questions.id = ?
    SQL
    
    Question.new(QuestionsDatabase.instance.execute(query, q_id).first)
  end
  
  def self.find_by_author_id(a_id)
    query = <<-SQL
      SELECT *
      FROM questions
      WHERE questions.author_id = ?
    SQL
    
    query_res = QuestionsDatabase.instance.execute(query, a_id)    
    query_res.map { |row| Question.new(row) }
  end

  def author
    User.find_by_id(self.author_id)
  end
  
  def replies
    Reply.find_by_question_id(self.id)
  end
  
  def followers
    QuestionFollower.followers_for_question_id(self.id)
  end
  
  # Return the top n most followed questions
  def most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end
  
  def likers
    QuestionLike.likers_for_question_id(self.id)
  end
  
  def num_liked
    QuestionLike.num_likes_for_question_id(self.id)
  end
  
  # Return the top n most liked questions
  def most_liked(n)
    QuestionLike.most_liked_questions(n)
  end
end