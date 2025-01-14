# class MysqlResult

*MysqlResult* object is the result returned for non-query commands on MySQL.

> @printable

## Properties

- *bytes* **`header`**: 
  
  The result header as returned in the Mysql connection.

- *int* **`affected_rows`**: 
  
  The number of rows affected by the corresponding Mysql command.

- *string* **`server_status`**: 
  
  The status of the server after executing the corresponding query.

- *string* **`warnings`**: 
  
  The warnings returned from Mysql in the result.

