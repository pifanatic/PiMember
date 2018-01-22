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
        $ script/create_db.sh
    ```

    to generate a new SQLite database that contains all necessary tables for
    PiMember to work.

3. Add some example cards (optional)

    To add some sample cards and categories type the following:

    ```
        $ script/add_sample_data.sh
    ```
