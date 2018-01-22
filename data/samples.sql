-- use these queries to generate some sample Cards

DELETE FROM 'Cards';
DELETE FROM 'Categories';

INSERT INTO 'Categories'
(name)
VALUES
('Capitals'),
('World Cup Wins'),
('Inhabitants');

INSERT INTO 'Cards'
(title, frontside, backside, category_id, rating, last_seen, due, correctly_answered, wrongly_answered)
VALUES
('Capital of Germany', 'What''s the capital of Germany?', 'Berlin', 1, 1, '01/01/2018', '02/01/2018', 1, 2),
('Capital of Spain', 'What''s the capital of Spain?', 'Madrid', 1, 2, '01/01/2018', '03/01/2018', 3, 2),
('Capital of France', 'What''s the capital of France?', 'Paris', 1, 1, '01/01/2018', '02/01/2018', 4, 2),
('Capital of the United States', 'What''s the capital of the United States?', 'Washington D.C.', 1, 3, '01/01/2018', '04/01/2018', 6, 0),
('German World Cup triumphs', 'How many World Cups has Germany won?', '4', 2, 1, '01/01/2018', '02/01/2018', 1, 2),
('Spanish World Cup triumphs', 'How many World Cups has Spain won?', '1', 2, 2, '01/01/2018', '03/01/2018', 4, 2),
('French World Cup triumphs', 'How many World Cups has France won?', '1', 3, 1, '01/01/2018', '04/01/2018', 5, 0),
('U.S. World Cup triumphs', 'How many World Cups have the U.S. won?', '0', 2, 1, '01/01/2018', '02/01/2018', 1, 2),
('Inhabitans of Germany', 'How many inhabitants does Germany have?', '82.5 Millions', 3, 1, '01/01/2018', '02/01/2018', 1, 2),
('Inhabitans of Spain', 'How many inhabitants does Spain have?', '46.4 Millions', 3, 2, '01/01/2018', '03/01/2018', 1, 2),
('Inhabitans of France', 'How many inhabitants does France have?', '66.9 Millions', 3, 1, '01/01/2018', '02/01/2018', 1, 2),
('Inhabitans of the U.S.', 'How many inhabitants do the U.S. have?', '322.7 Millions', 3, 4, '01/01/2018', '06/01/2018', 7, 2);
