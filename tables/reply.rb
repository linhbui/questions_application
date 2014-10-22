require 'singleton'
require 'sqlite3'
require_relative '../questions'

class Reply
  
  attr_accessor :question_id, :parent_id, :body, :author_id
  attr_reader :id
  
  def self.all 
    results = QuestionsDatabase.instance.execute('SELECT * FROM replies')
    results.map { |result| Reply.new(result) }
  end
  
  def initialize(options = {})
    @id, @question_id, @parent_id, @author_id, @body =
    options.values_at('reply_id', 'question_id', 'parent_id', 'author_id', 'body')
  end
  
  def save
    params = [self.question_id, self.parent_id, self.body, self.author_id]
    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, *params)
      INSERT INTO
      replies (question_id, parent_id, body, author_id)
      VALUES
      (?, ?, ?, ?)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, *params, self.id)
      UPDATE replies
      SET
        question_id = ?,
        parent_id   = ?,
        body        = ?,
        author_id   = ?
      WHERE id = ?
      SQL
    end
  end
  
  def find_by_id(id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE replies.reply_id = ?
    SQL
    
    Reply.new(QuestionsDatabase.instance.execute(query, id).first)
  end
  
  def self.find_by_question_id(q_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE replies.question_id = ?
    SQL
    query_res = QuestionsDatabase.instance.execute(query, q_id)      
    query_res.map { |row| Reply.new(row) }
  end
  
  def self.find_by_parent_id(r_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE replies.parent_id = ?
    SQL
    query_res = QuestionsDatabase.instance.execute(query, r_id)      
    query_res.map { |row| Reply.new(row) }
  end
  
  def self.find_by_author_id(w_id)
    query = <<-SQL
    SELECT *
    FROM replies
    WHERE replies.author_id = ?
    SQL
  
    query_res = QuestionsDatabase.instance.execute(query, w_id)      
    query_res.map { |row| Reply.new(row) }
  end
  
  # return the author of the reply
  def author
    User.find_by_id(self.author_id)
  end
  
  # return the question of self
  def question
    Question.find_by_id(self.question_id)
  end
  
  # return the parent reply of self
  def parent_reply
    Reply.find_by_id(self.parent_id)
  end
  
  # return all the child replies of self
  def child_replies
    Reply.find_by_parent_id(self.id)    
  end
end
