# Installation

1. Dependencies

All required dependencies for PiMember are listed in the cpanfile. In order to
install these you can run

```
    $ cpanm --installdeps .
```

2. Database initialization

PiMember uses a SQLite database to store its cards so make sure you have sqlite3
installed. If this is the case you can simply run

```
    $ cat script/init.sql | sqlite3 <db_name>
```

to generate a new SQLite database that contains all necessary tables for
PiMember to work.
