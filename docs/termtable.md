# class TermTable

*TermTable* class implements a simple terminal based table that can be used to display *MysqlResultSet* in CLI based applications.

#### Constructor

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

## Methods

- **`render()`**:
  
  Renders the table to string.
  
  - **Returns:** *string*
