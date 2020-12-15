-- generate the tables needed for PiMember

DROP TABLE IF EXISTS 'Users';
DROP TABLE IF EXISTS 'Cards';
DROP TABLE IF EXISTS 'Tags';
DROP TABLE IF EXISTS 'CardsTags';

CREATE TABLE 'Users' (
    id            INTEGER   PRIMARY KEY,
    username      TEXT,
    password      TEXT,
    first_name    TEXT
);

CREATE TABLE 'Cards' (
    id                      INTEGER     PRIMARY KEY,
    title                   TEXT,
    frontside               TEXT        NOT NULL,
    backside                TEXT        NOT NULL,
    rating                  INTEGER     NOT NULL,
    created                 DATETIME    NOT NULL,
    last_seen               DATETIME,
    due                     DATE,
    correct_answers         INTEGER,
    wrong_answers           INTEGER,
    in_trash                INTEGER     NOT NULL    DEFAULT 0
);

CREATE TABLE 'Tags' (
    id                      INTEGER     PRIMARY KEY,
    name                    TEXT        NOT NULL
);

CREATE TABLE 'CardsTags' (
    id                      INTEGER     PRIMARY KEY,
    card_id                 INTEGER     NOT NULL,
    tag_id                  INTEGER     NOT NULL,
    FOREIGN KEY(card_id) REFERENCES Cards(id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(tag_id) REFERENCES Tags(id) ON UPDATE CASCADE ON DELETE CASCADE
);
