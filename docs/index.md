# mysql

A MySQL client implemented in pure Blade.


## Installation

You can install the tar library with [Nyssa package manager](https://nyssa.bladelang.com)

```
nyssa install mysql
```

## Important Notice

- The library currently only supports MySQL 5.7 and below.
- There is no support for prepared statements yet.

## Connecting to MySQL

You can connect to a MySQL instance after creating a valid Mysql object by calling the `connect()` method on the object. For example:

```js
import mysql

var con = mysql('localhost', 3306, 'root', '')
if con.connect() echo 'Connected!'
else echo 'Connection failed!'
```

You can initialize the database you want to use when creating the object like this:

```js
import mysql

var con = mysql('localhost', 3306, 'root', '', 'myapp')
if con.connect() echo 'Connected to DB myapp!'
else echo 'Connection failed to DB myapp!'
```

**Note** that if you do not specify the name of the database, you will need to call the `use_db()` method to initialize a database before you run your queries like this:

```js
import mysql

var con = mysql('localhost', 3306, 'root', '')
if con.connect() {
  con.use_db('my_application_db')

  # Run queries here...
} else {
  echo 'Connection failed!'
}
```

## Running queries

After successfully connecting to a MySQL instance and initialized a database, you can run your queries using the `query()` method. It is important to note query method either returns a [MysqlResult](#class-mysqlresult) or [MysqlResultSet](#class-mysqlresultset), the later only being returned for queries that return rows while other queries return the former.

```js
var result = con.query('SELECT * FROM users')
echo result.rows
echo result.fields
```

You can iterate over a *MysqlResultSet* using the for loop because it is an iterable.

E.g.

```js
for user in con.query('SELECT * FROM users WHRE id <=> 5') {
  echo user.email
}
```

When you run an `INSERT` operation, you can retrieve the last insert ID from the Mysql object iteself like in this example:

```
con.query("INSERT INTO table (name, age) VALUES ('Kelly Clarkson', 25);")
echo con.last_insert_id
```

For querys that do not return rows, you can easily get the number of affected rows like in the following:

```js
var result = con.query('DELETE FROM users WHERE deleted_at != NULL;')
echo result.affected_rows
```

See [MysqlResult](#class-mysqlresult) and [MysqlResultSet](#class-mysqlresultset) for more.

## Display result in CLI applications

The library comes with an handy class for CLI based applications to display MySQL tables in the terminal/command prompts &mdash; *TermTable*. Here is a basic usage.

```js
var result = con.query('SELECT * FROM users')
echo mysql.TermTable(result).render()
```

You should see something similar to this:

```s
+------------+--------------+-------------------+---------------------+
| id(20) +PK | name(196605) | phone(42)         | created_at(19)      |
+------------+--------------+-------------------+---------------------+
| 1          | Richard      | +2349070776001    | 2023-01-25 08:20:38 |
| 2          | Aderonke     | +37019353407      | 2023-01-25 13:40:31 |
| 3          | Jayes Webber | +44723276483      | 2023-01-25 16:23:24 |
| 4          | Kendrick     | 08172345678       | 2023-01-25 21:29:58 |
| 5          | Queen        | +4490777167728    | 2023-01-25 21:30:45 |
| 6          | Alexander    | 0901129884992     | 2023-01-31 16:22:34 |
+------------+--------------+-------------------+---------------------+
```

See [TermTable](#class-termtable) for more information.

## Library Functions

- **`mysql(host, port, user, password [, db])`**:
  
  Returns a new instance of the Mysql object.

  - **Parameters:**
    - *string* `host`
    - *number* `port`
    - *string* `username`
    - *string* `password`
    - *string* `database` (Optional)
  - **Returns:** `Mysql`

## Library Classes

- ### **`Mysql`**
  
  Mysql class implements the features need for Mysql database connection and queries.

  - **Constructor**:
    - *string* `host`
    - *number* `port`
    - *string* `username`
    - *string* `password`
    - *string* `database` (Optional)

  - **Variables:**
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

  - **Methods:**
  - **`connect()`**: Connects to the database.
    - **Returns:** *bool* indicating if the connection was successful or not.
    - **Throws:** *MysqlException*

  - **`use_db(db)`**: Changes the active database.
    - **Parameters:**
      - *string* `db`: The name of the database.
    - **Returns:** *bool*
    - **Throws:** *MysqlException*

  - **`databases()`**: Returns a list of the databases on the server.
    - **Returns:** *List&lt;string&gt;* containing the name of the databases in the MySQL instance.
    - **Throws:** *MysqlException* when the instance is in an invalid state.

  - **`query(sql)`**: Runs a database query and returns the result or throw *MysqlException* if it fails.
    - **Parameters:**
      - *string* `sql`: The SQL query.
    - **Returns:** *MysqlResult | MysqlResultSet*
    - **Throws:** *MysqlException*
    
    > *MysqlResultSet* is only returned for SELECT and similar queries.

  - **`close()`**: Closes the database connection.




- ### **`MysqlResult`**

  *MysqlResult* object is the result returned for non-query commands on MySQL.

  - **Variables:**
    - *bytes* `header`: The result header as returned in the Mysql connection.
    - *int* `affected_rows`: The number of rows affected by the corresponding Mysql command.
    - *string* `server_status`: The status of the server after executing the corresponding query.
    - *string* `warnings`: The warnings returned from Mysql in the result.

- ### **`MysqlResultSet`**

  *MysqlResultSet* object is the result returned from a query like operation on MySQL table.

  - **Variables:**
  - *List&lt;dictionary&gt;* `fields`: The table fields returned in the response. 

    Each dictionary contains the following entries:

    - *string* `database`
    - *string* `table`
    - *string* `name`
    - *string* `original_name`
    - *number* `length`
    - *number* `field_type`
    - *dictionary* `flags`
    
    The `flags` dictionary contain the following entries:

    - *bool* `not_null`
    - *bool* `primary_key`
    - *bool* `unique_key`
    - *bool* `multiple_key`
    - *bool* `blob`
    - *bool* `unsigned`
    - *bool* `zero_fill`
    - *bool* `binary`
    - *bool* `enum`
    - *bool* `auto_increment`
    - *bool* `timestamp`
    - *bool* `set`

  - *List&lt;dictionary&gt;* `rows`: The result rows returned from the query. The content of each dictionary will based on the result of a query.

- ### **`TermTable`**

  *TermTable* class implements a simple terminal based table that can be used to display *MysqlResultSet* in CLI based applications.

  - **Constructor:**
    - *MysqlResultSet* `result`: A valid resultset returned from Mysql::query()
    - *dictionary* `options`: Used for configuring how TermTable displays data.

  > The options dictionary can contain one or more of the following entries:
  >
  > - *bool* `show_header` [default: true]
  > - *bool* `show_primary_key` [default: false]
  > - *bool* `show_foreign_key` [default: false]
  > - *bool* `show_length`  [default: false]
  > - *string* `primary_key_text` [default: `+PK`]
  > - *string* `foriegn_key_text` [default: `+FK`]

  - **Methods:**
    - **`render()`**: Renders the table to string.

      - **Returns:** *string*


- ### **`MysqlException`** *inherits* *Exception*

  Mysql Exception class. This class represents all kinds of MySQL errors.

  - **Variables:**
    - *int* `error_code`: The MySQL error code
    - *string* `sql_state`: The MySQL state when the exception occurred.
    - *string* `error_message`: The error message as returned by MySQL without it's exception formatting.


### License

[MIT](https://github.com/mcfriend99/mysql/blob/main/LICENSE)