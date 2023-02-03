# class MysqlResultSet

*MysqlResultSet* object is the result returned from a query like operation on MySQL table.

## Properties

- *List&lt;dictionary&gt;* **`fields`**: 
  
  The table fields returned in the response. 

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

- *List&lt;dictionary&gt;* **`rows`**: 
  
  The result rows returned from the query. The content of each dictionary will based on the result of a query.

