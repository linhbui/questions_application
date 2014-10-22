CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(30) NOT NULL,
  lname VARCHAR(30) NOT NULL
);

INSERT INTO
  users (fname, lname)
VALUES
  ("Wei", "Li"), ("Linh", "Bui"), ("Sophie", "Poodle");
  
CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255),
  body TEXT NOT NULL,
  author_id INTEGER NOT NULL,
  FOREIGN KEY (author_id) REFERENCES users(id)
);

-- Insert seed questions
INSERT INTO
  questions (title, body, author_id)
SELECT
  "Wei's Question", "What's the meaning of life", users.id
FROM
  users
WHERE
  users.fname = "Wei" AND users.lname = "Li";

INSERT INTO
  questions (title, body, author_id)
SELECT
  "Linh's Question", "When will the universe end", users.id
FROM
  users
WHERE
  users.fname = "Linh" AND users.lname = "Bui";

INSERT INTO
  questions (title, body, author_id)
SELECT
  "Sophie's Question", "WOOF!!", users.id
FROM
  users
WHERE
  users.fname = "Sophie" AND users.lname = "Poodle";

INSERT INTO
  questions (title, body, author_id)
SELECT
  "Sophie's Question 2", "WOOF WOOF!!", users.id
FROM
  users
WHERE
  users.fname = "Sophie" AND users.lname = "Poodle";
-- support the many-to-many relationship between questions and users 
-- (a user can have many questions she is following, and a question can 
-- have many followers).
CREATE TABLE question_followers (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- Create follows
INSERT INTO
  question_followers (user_id, question_id)
SELECT
  users.id, questions.id
FROM
  users
JOIN
  questions
WHERE
  (users.fname = "Wei" AND users.lname = "Li"
    AND questions.title = "Sophie's Question");

INSERT INTO
  question_followers (user_id, question_id)
SELECT
  users.id, questions.id
FROM
  users
JOIN
  questions
WHERE
  (users.fname = "Linh" AND users.lname = "Bui"
    AND questions.title = "Sophie's Question");

-- Replies can have parents. Keep track of writer & question
CREATE TABLE replies (
  reply_id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_id INTEGER,
  author_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (parent_id) REFERENCES replies(reply_id)
  FOREIGN KEY (author_id) REFERENCES users(id)
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- Users can like a question.
CREATE TABLE question_likes (
  user_id INTEGER NOT NULL,
  question_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)  
);

INSERT INTO
  question_likes (user_id, question_id)
SELECT
  users.id, questions.id
FROM
  users
JOIN
  questions
WHERE
  (users.fname = "Linh" AND users.lname = "Bui"
    AND questions.title = "Sophie's Question");

INSERT INTO
  question_likes (user_id, question_id)
SELECT
  users.id, questions.id
FROM
  users
JOIN
  questions
WHERE
  (users.fname = "Wei" AND users.lname = "Li"
    AND questions.title = "Sophie's Question");

INSERT INTO
  question_likes (user_id, question_id)
SELECT
  users.id, questions.id
FROM
  users
JOIN
  questions
WHERE
  (users.fname = "Linh" AND users.lname = "Bui"
    AND questions.title = "Sophie's Question");
    
INSERT INTO
  question_likes (user_id, question_id)
SELECT
  users.id, questions.id
FROM
  users
JOIN
  questions
WHERE
  (users.fname = "Wei" AND users.lname = "Li"
    AND questions.title = "Sophie's Question 2");