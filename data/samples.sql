-- use these queries to generate some sample Cards

DELETE FROM 'Cards';
DELETE FROM 'Tags';
DELETE FROM 'CardsTags';

INSERT INTO 'Tags'
(name)
VALUES
('capitals'),
('world-cup-wins'),
('inhabitants'),
('multiple');

INSERT INTO 'Cards'
(title, frontside, backside, rating, last_seen, due, correct_answers, wrong_answers)
VALUES
('Capital of Germany', 'What''s the capital of Germany?', 'Berlin', 1, '2018-01-01', '2018-01-02', 1, 2),
('Capital of Spain', 'What''s the capital of Spain?', 'Madrid', 2, '2018-01-01', '2018-01-03', 3, 2),
('Capital of France', 'What''s the capital of France?', 'Paris', 1, '2018-01-01', '2018-01-02', 4, 2),
('Capital of the United States', 'What''s the capital of the United States?', 'Washington D.C.', 3, '2018-01-01', '2018-01-04', 6, 0),
('German World Cup triumphs', 'How many World Cups has Germany won?', '4', 1, '2018-01-01', '2018-01-02', 1, 2),
('Spanish World Cup triumphs', 'How many World Cups has Spain won?', '1', 2, '2018-01-01', '2018-01-03', 4, 2),
('French World Cup triumphs', 'How many World Cups has France won?', '1', 1, '2018-01-01', '2018-01-04', 5, 0),
('U.S. World Cup triumphs', 'How many World Cups have the U.S. won?', '0', 1, '2018-01-01', '2018-01-02', 1, 2),
('Inhabitans of Germany', 'How many inhabitants does Germany have?', '82.5 Millions', 1, '2018-01-01', '2018-01-02', 1, 2),
('Inhabitans of Spain', 'How many inhabitants does Spain have?', '46.4 Millions', 2, '2018-01-01', '2018-01-03', 1, 2),
('Inhabitans of France', 'How many inhabitants does France have?', '66.9 Millions', 1, '2018-01-01', '2018-01-02', 1, 2),
('Inhabitans of the U.S.', 'How many inhabitants do the U.S. have?', '322.7 Millions', 4, '2018-01-01', '2018-01-06', 7, 2);

INSERT INTO 'CardsTags'
(card_id, tag_id)
VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 2),
(6, 2),
(7, 2),
(8, 2),
(9, 3),
(10, 3),
(11, 3),
(12, 3),
(1, 4),
(4, 4),
(5, 4),
(10, 4),
(11, 4),
(12, 4);
