/**
 * A MySQL client implemented in pure Blade.
 */

import socket {
  Socket,
  AF_INET,
  SOCK_STREAM,
  get_address_info
}
import .packets { * }
import .termtable { * }
import .result { * }
import .exception { * }

/**
 * The Mysql class implements the features need for Mysql database connection and queries.
 */
class Mysql {
  var _client
  var _db

  /**
   * A dictionary containing information about the current MySQL instance.
   * 
   * The dictionary contains the following entries:
   * 
   * - string `protocol`
   * - string `server_version`
   * - string `connection_id`
   * - dictionary `server_capabilities`
   *   
   *   This dictionary contains the following subentries:
   * 
   *   - bool `Long Password`
   *   - bool `Found Rows`
   *   - bool `Long Column Flags`
   *   - bool `Connect With Database`
   *   - bool `Don't Allow database.table.column`
   *   - bool `Can use compression protocol`
   *   - bool `ODBC Client`
   *   - bool `Can Use LOAD DATA LOCAL`
   *   - bool `Ignore Spaces before '('`
   *   - bool `Speaks 4.1 protocol (new flag)`
   *   - bool `Interactive Client`
   *   - bool `Switch to SSL after handshake`
   *   - bool `Ignore sigpipes`
   *   - bool `Knows about transactions`
   *   - bool `Speaks 4.1 protocol (old flag)`
   *   - bool `Can do 4.1 authentication`
   *
   * - string `server_language`
   * - string `server_status`
   * - dictionary `server_extended_capabilities`
   * 
   *   This dictionary contains the following entries:
   * 
   *   - *bool* `Multiple statements`
   *   - *bool* `Multiple results`
   *   - *bool* `PS Multiple results`
   *   - *bool* `Plugin Auth`
   *   - *bool* `Connect attrs`
   *   - *bool* `Plugin Auth LENENC Client Data`
   *   - *bool* `Client can handle expired passwords`
   *   - *bool* `Session variable tracking`
   *   - *bool* `Deprecate EOF`
   * 
   * - string `authentication_plugin`
   */
  var info = {
    protocol: nil,
    server_version: nil,
    connection_id: nil,
    server_capabilities: nil,
    server_language: nil,
    server_status: nil,
    server_extended_capabilities: nil,
    authentication_plugin: nil,
  }

  /**
   * The ID of the last databse insert operation.
   * @type number
   */
  var last_insert_id = 0

  /**
   * Returns a new instance of the Mysql object.
   * 
   * @param string host
   * @param number port
   * @param string username
   * @param string password
   * @param string database (Optional)
   */
  Mysql(host, port, username, password, database) {
    self.host = host
    self.port = port
    self.user = username
    self.password = password
    self._db = database
  }

  _init() {
    self._client = Socket(AF_INET, SOCK_STREAM)
    var address = get_address_info(self.host)
    self._client.connect(address.ip, self.port)
    return true
  }

  _clean_info(info) {
    var inf = {}
    inf.extend(info)
    inf.remove('packet_name')
    inf.remove('packet_length')
    inf.remove('packet_number')
    inf.remove('salt1')
    inf.remove('unused')
    inf.remove('salt2')
    inf.remove('authentication_plugin_length')
    inf.server_extended_capabilities.remove('unused1')
    inf.server_extended_capabilities.remove('unused2')
    inf.server_extended_capabilities.remove('unused3')
    inf.server_extended_capabilities.remove('unused4')
    inf.server_extended_capabilities.remove('unused5')
    inf.server_extended_capabilities.remove('unused6')
    inf.server_extended_capabilities.remove('unused7')
    return inf
  }

  _detect_packet(resp) {
    if resp[4] == 0x00 return OkPacket(resp)
    else if resp[4] == 0xFF return ErrorPacket(resp)
    else if resp[4] == 0xFE return EofPacket(resp)
    return QueryResponsePacket(resp)
  }

  # Sending authentication packet
  _login(handshake_packet, packet_number) {
    if !self._client {
      die MysqlException('Client Error: Invalid state.')
    }

    var login_packet = LoginPacket(handshake_packet)
    var packet = login_packet.create_packet(self.user, self.password, packet_number)
    self._client.send(packet)
    var resp = self._detect_packet(self._client.receive(65536).to_bytes())

    if instance_of(resp, ErrorPacket) {
      var info = resp.parse()
      die MysqlException(info)
    } else if instance_of(resp, OkPacket) {
      return resp.parse().packet_number
    } else if instance_of(resp, EofPacket) {
      return false
    }
    return nil
  }

  /**
   * Connects to the database
   * 
   * @returns bool indicating if the connection was successful or not.
   * @throws MysqlException
   */
  connect() {
    if !self._client {
      self._init()
    }

    var resp = self._client.receive(65536)
    var handshake = HandshakePacket(resp.to_bytes())

    var info = handshake.parse()
    self.info = self._clean_info(info)

    if self._login(handshake, info.packet_number+1) {
      if !self._db return true
      return self.use_db(self._db)
    }

    return false
  }

  /** 
   * Changes the active database.
   * 
   * @param string db The name of the database.
   * @returns bool
   * @throws MysqlException
   */
  use_db(db) {
    if !self._client {
      die MysqlException('Client Error: Invalid state.')
    }

    var packet = InitDBPacket(db).create_packet()
    self._client.send(packet)
    var resp = self._detect_packet(self._client.receive(65536).to_bytes())

    if instance_of(resp, ErrorPacket) {
      var info = resp.parse()
      die MysqlException(info)
    } else if instance_of(resp, OkPacket) {
      self._db = db
      return true
    }

    return false
  }

  /** 
   * Returns a list of the databases on the server.
   * 
   * @returns List<string> containing the name of the databases in the MySQL instance.
   * @throws MysqlException when the instance is in an invalid state
   */
  databases() {
    if !self._client {
      die MysqlException('Client Error: Invalid state.')
    }

    var show_dbs = ShowDatabasesPacket()
    var packet = show_dbs.create_packet()
    self._client.send(packet)
    return show_dbs.parse(self._client.receive(65536).to_bytes())
  }

  /**
   * Runs a database query and returns the result or throw MysqlException if it fails.
   * 
   * @param string sql The SQL query
   * @return MysqlResult|MysqlResultSet
   * @throws MysqlException
   * @note MysqlResultSet is only returned for SELECT and similar queries.
   */
  query(sql) {
    if !self._client {
      die MysqlException('Client Error: Invalid state.')
    }

    var packet = QueryPacket(sql).create_packet()
    self._client.send(packet)
    try {
      packet = self._detect_packet(self._client.receive(65536).to_bytes())
    } catch Exception err {
      return {packet_name: 'unknown'}
    }

    # reset the last insert id
    self.last_insert_id = 0

    var resp = packet.parse()
    if resp.packet_name == 'EofPackage'
      die MysqlException('EOF encountered')
    else if resp.packet_name == 'ErrPacket'
      die MysqlException(resp)
    
    if resp.packet_name == 'OkPacket' {
      self.last_insert_id = resp.last_insert_id
      return MysqlResult(resp.header, resp.affected_rows, resp.server_status, resp.warnings)
    }
    
    return MysqlResultSet(resp)
  }

  /**
   * Closes the database connection.
   */
  close() {
    if self._client {
      self._client.send(QuitPacket().create_packet())
      self._client.close()
    }
  }
}

/**
 * Returns a new instance of the Mysql object.
 * 
 * @param string host
 * @param number port
 * @param string username
 * @param string password
 * @param string database (Optional)
 * @returns Mysql
 * @default
 */
def mysql(host, port, username, password, database) {
  return Mysql(host, port, username, password, database)
}
