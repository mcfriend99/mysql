# class Mysql
  
The Mysql class implements the features need for Mysql database connection and queries.

#### **Constructor**:

  - *string* `host`
  - *number* `port`
  - *string* `username`
  - *string* `password`
  - *string* `database` (Optional)

## Properties

- *dictionary* **`info`**: A dictionary containing information about the current MySQL instance.

  The dictionary contains the following entries:

  - *string* `protocol`
  - *string* `server_version`
  - *string* `connection_id`
  - *dictionary* `server_capabilities`
    
    This dictionary contains the following subentries:
    
    - *bool* `Long Password`
    - *bool* `Found Rows`
    - *bool* `Long Column Flags`
    - *bool* `Connect With Database`
    - *bool* `Don't Allow database.table.column`
    - *bool* `Can use compression protocol`
    - *bool* `ODBC Client`
    - *bool* `Can Use LOAD DATA LOCAL`
    - *bool* `Ignore Spaces before '('`
    - *bool* `Speaks 4.1 protocol (new flag)`
    - *bool* `Interactive Client`
    - *bool* `Switch to SSL after handshake`
    - *bool* `Ignore sigpipes`
    - *bool* `Knows about transactions`
    - *bool* `Speaks 4.1 protocol (old flag)`
    - *bool* `Can do 4.1 authentication`

  - *string* `server_language`
  - *string* `server_status`
  - *dictionary* `server_extended_capabilities`

    This dictionary contains the following entries:

    - *bool* `Multiple statements`
    - *bool* `Multiple results`
    - *bool* `PS Multiple results`
    - *bool* `Plugin Auth`
    - *bool* `Connect attrs`
    - *bool* `Plugin Auth LENENC Client Data`
    - *bool* `Client can handle expired passwords`
    - *bool* `Session variable tracking`
    - *bool* `Deprecate EOF`

  - *string* `authentication_plugin`
  
- *int* **`last_insert_id`**: The numeric ID of the last databse insert operation.

## Methods

- **`connect()`**:
  
  Connects to the database.
  
  - **Returns:** *bool* indicating if the connection was successful or not.
  - **Throws:** *MysqlException*

- **`use_db(db)`**: 
  
  Changes the active database.
  
  - **Parameters:**
    - *string* `db`: The name of the database.
  - **Returns:** *bool*
  - **Throws:** *MysqlException*

- **`databases()`**: 
  
  Returns a list of the databases on the server.
  
  - **Returns:** *List&lt;string&gt;* containing the name of the databases in the MySQL instance.
  - **Throws:** *MysqlException* when the instance is in an invalid state.

- **`query(sql)`**: 
  
  Runs a database query and returns the result or throw *MysqlException* if it fails.
  
  - **Parameters:**
    - *string* `sql`: The SQL query.
  - **Returns:** *MysqlResult | MysqlResultSet*
  - **Throws:** *MysqlException*
  
  > *MysqlResultSet* is only returned for SELECT and similar queries.

- **`close()`**: 
  
  Closes the database connection.

