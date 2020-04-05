-- generate the tables needed for PiMember

DROP TABLE IF EXISTS 'Users';
DROP TABLE IF EXISTS 'Cards';
DROP TABLE IF EXISTS 'Categories';

CREATE TABLE Users (
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
    category_id             INTEGER,
    rating                  INTEGER     NOT NULL,
    last_seen               DATETIME,
    due                     DATE,
    correctly_answered      INTEGER,
    wrongly_answered        INTEGER,
    FOREIGN KEY(category_id) REFERENCES Categories(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE 'Categories' (
    id                      INTEGER     PRIMARY KEY,
    name                    TEXT        NOT NULL
);
