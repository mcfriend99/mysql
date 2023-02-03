# mysql

A MySQL client implemented in pure Blade.


## Installation

You can install the tar library with [Nyssa package manager](https://nyssa.bladelang.com)

```
nyssa install mysql
```

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

After successfully connecting to a MySQL instance and initialized a database, you can run your queries using the `query()` method. It is important to note query method either returns a [MysqlResult](mysqlresult) or [MysqlResultSet](mysqlresultset), the later only being returned for queries that return rows while other queries return the former.

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

```js
con.query("INSERT INTO table (name, age) VALUES ('Kelly Clarkson', 25);")
echo con.last_insert_id
```

For querys that do not return rows, you can easily get the number of affected rows like in the following:

```js
var result = con.query('DELETE FROM users WHERE deleted_at != NULL;')
echo result.affected_rows
```

See [MysqlResult](mysqlresult) and [MysqlResultSet](mysqlresultset) for more.

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

See [TermTable](termtable) for more information.


## Important Notice

- The library currently only supports MySQL 5.7 and below.
- There is no support for prepared statements yet.

### License

[MIT](https://github.com/mcfriend99/mysql/blob/main/LICENSE)