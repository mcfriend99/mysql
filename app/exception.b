/**
 * Mysql Exception class. This class represents all kinds of MySQL errors.
 * 
 * @extends Exception
 */
class MysqlException < Exception {
  /**
   * The MySQL error code.
   * @type int
   */
  var error_code = 0

  /**
   * The MySQL state when the exception occurred.
   * @type string
   */
  var sql_state = 'HY0000'

  /**
   * The error message as returned by MySQL without it's exception formatting.
   * @type string
   */
  var error_message = ''

  # /**
  #  * MysqlException constructor
  #  * 
  #  * @param string|ErrorPacket message
  #  * @returns MysqlException
  #  */
  MysqlException(message) {
    if is_string(message)
      self.message = message
    else {
      self.error_code = message.error_code
      self.sql_state = message.sql_state
      self.error_message = message.error_message
      self.message = 'Error: ${message.error_code} - ${message.error_message}'
    }
  }
}
