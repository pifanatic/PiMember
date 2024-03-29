# Installation

## Dependencies

All required dependencies for PiMember are listed in `Makefile.PL`. In order to
install these you can run

```
    $ perl Makefile.PL
    $ make
    $ make test
    $ make install
```

**Note:** To get the full Catalyst experience during the development process
you should also install `Catalyst::Devel`. See the [docs](https://metacpan.org/pod/Catalyst::Devel)
for more information.

## Database initialization

PiMember uses a SQLite database to store its cards so make sure you have sqlite3
installed. If this is the case you can simply run

```
    $ script/create_db.sh
```

to generate a new SQLite database that contains all necessary tables for
PiMember to work.

## Start the server

```
    $ script/pimember_server.pl
```

## Create your account

Point your browser to your PiMember instance and you will be greeted by a form
to set up your user account.