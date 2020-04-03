script/pimember_create.pl  \
    model                  \
    DB                     \
    DBIC::Schema           \
    PiMember::Schema       \
    create=static          \
    dbi:SQLite:pimember.db \
    on_connect_do="PRAGMA foreign_keys = ON"
