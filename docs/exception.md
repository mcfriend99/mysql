# class MysqlException

Mysql Exception class. This class represents all kinds of MySQL errors.

## Properties

- *int* **`error_code`**: 
  
  The MySQL error code.

- *string* **`sql_state`**: 
  
  The MySQL state when the exception occurred.

- *string* **`error_message`**: 
  
  The error message as returned by MySQL without it's exception formatting.

