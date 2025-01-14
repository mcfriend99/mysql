/**
 * MysqlResult object is the result returned for non-query commands on MySQL.
 * 
 * @printable
 */
class MysqlResult {
  /**
   * The result header as returned in the Mysql connection.
   * @type bytes
   */
  var header

  /**
   * The number of rows affected by the corresponding Mysql command.
   * @type int
   */
  var affected_rows

  /**
   * The status of the server after executing the corresponding query.
   * @type string
   */
  var server_status

  /**
   * The warnings returned from Mysql in the result.
   * @type string
   */
  var warnings
  
  MysqlResult(header, affected_rows, server_status, warnings) {
    self.header = header
    self.affected_rows = affected_rows
    self.server_status = server_status
    self.warnings = warnings
  }

  @to_string() {
    return '<MysqlResult affected_rows=${affected_rows} warnings=(${warnings})>'
  }
}

/**
 * MysqlResultSet object is the result returned from a query like operation on MySQL table.
 * 
 * @printable
 * @serializable
 * @iterable
 */
class MysqlResultSet {
  /**
   * The table fields returned in the response.
   * @type List<dictionary>
   * 
   * Each dictionary contains the following entries:
   * 
   * - string `database`
   * - string `table`
   * - string `name`
   * - string `original_name`
   * - number `length`
   * - number `field_type`
   * - dictionary `flags`
   * 
   * The `flags` dictionary entry in the field has the following entries:
   * 
   * - bool `not_null`
   * - bool `primary_key`
   * - bool `unique_key`
   * - bool `multiple_key`
   * - bool `blob`
   * - bool `unsigned`
   * - bool `zero_fill`
   * - bool `binary`
   * - bool `enum`
   * - bool `auto_increment`
   * - bool `timestamp`
   * - bool `set`
   */
  var fields

  /**
   * The result rows returned from the query.
   * @type List<dictionary>
   */
  var rows

  MysqlResultSet(packet) {
    self.fields = packet.fields
    self.rows = packet.rows
  }

  @to_string() {
    return '<MysqlResultSet rows=${self.rows.length()} fields=${self.fields.length()}>'
  }

  @to_json() {
    return self.rows
  }

  @itern(n) {
    var length = self.rows.length()
    if length == 0 return false

    if x == nil return 0

    if x < length - 1
      return x + 1
    
    return false
  }

  @iter(n) {
    return self.rows[n]
  }
}
