script/pimember_create.pl  \
    model                  \
    DB                     \
    DBIC::Schema           \
    PiMember::Schema       \
    create=static          \
    use_moose=1            \
    overwrite_modifications=1 \
    dbi:SQLite:pimember.db \
    on_connect_do="PRAGMA foreign_keys = ON"
