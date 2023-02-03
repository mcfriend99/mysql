import hash
import struct
import iters
import .util
import .types { * }


# Data between client and server is exchanged in packets of max 16MByte size.
class MysqlPacket {
  MysqlPacket(resp) {
    if !resp resp = bytes(0)

    self.resp = resp
    self.start = 0
    self.end = 0

    self.client_capabilities = {
      'Long Password': true,
      'Found Rows': false,
      'Long Column Flags': true,
      'Connect With Database': false,
      'Don\'t Allow database.table.column': false,
      'Can use compression protocol': false,
      'ODBC Client': false,
      'Can Use LOAD DATA LOCAL': false,
      'Ignore Spaces before \'(\'': false,
      'Speaks 4.1 protocol (new flag)': true,
      'Interactive Client': true,
      'Switch to SSL after handshake': false,
      'Ignore sigpipes': false,
      'Knows about transactions': true,
      'Speaks 4.1 protocol (old flag)': false,
      'Can do 4.1 authentication': true,
    }

    self.extended_client_capabilities = {
      'Multiple statements': true,
      'Multiple results': true,
      'PS Multiple results': true,
      'Plugin Auth': true,
      'Connect attrs': false,
      'Plugin Auth LENENC Client Data': false,
      'Client can handle expired passwords': false,
      'Session variable tracking': false,
      'Deprecate EOF': false,
      'unused1': false,
      'unused2': false,
      'unused3': false,
      'unused4': false,
      'unused5': false,
      'unused6': false,
      'unused7': false,
    }

    self.charsets = {
      1: 'big5_chinese_ci', 
      2: 'latin2_czech_cs', 
      3: 'dec8_swedish_ci', 
      4: 'cp850_general_ci',
      5: 'latin1_german1_ci',
      6: 'hp8_english_ci',
      7: 'koi8r_general_ci',
      8: 'latin1_swedish_ci',
      9: 'latin2_general_ci',
      10: 'swe7_swedish_ci',
      33: 'utf8_general_ci',
      63: 'binary',
    }

    self.commands = {
      COM_SLEEP: 0x00,
      COM_QUIT: 0x01,
      COM_INIT_DB: 0x02,
      COM_QUERY: 0x03,
    }
  }

  next(length, type, freeze) {
    if !type type = 'int'
    if !freeze freeze = false

    var portion
    if !freeze {
      if length {
        self.end += length
        portion = self.resp[self.start,self.end]
        self.start = self.end
      } else {
        portion = self.resp[self.start,]
        self.start = self.end = 0
      }
    } else {
      if length portion = self.resp[self.start, self.start + length]
      else portion = self.resp[self.start,]
    }

    if portion[-1] == 0 and type == 'str' portion = portion[,-1]

    if type == 'int' return util.int_from_bytes(portion)
    else if type == 'str' return portion.to_string()
    else if type == 'hex' return util.bytes_to_hex(portion)
    else return portion
  }

  # See: https://dev.mysql.com/doc/internals/en/capability-flags.html#packet-Protocol::CapabilityFlags
  get_server_capabilities(resp) {
    return {
      'Long Password': resp&1 != 0,
      'Found Rows': resp&2 != 0,
      'Long Column Flags': resp&3 != 0,
      'Connect With Database': resp&4 != 0,
      'Don\'t Allow database.table.column': resp&5 != 0,
      'Can use compression protocol': resp&6 != 0,
      'ODBC Client': resp&7 != 0,
      'Can Use LOAD DATA LOCAL': resp&8 != 0,
      'Ignore Spaces before \'(\'': resp&9 != 0,
      'Speaks 4.1 protocol (new flag)': resp&10 != 0,
      'Interactive Client': resp&11 != 0,
      'Switch to SSL after handshake': resp&12 != 0,
      'Ignore sigpipes': resp&13 != 0,
      'Knows about transactions': resp&14 != 0,
      'Speaks 4.1 protocol (old flag)': resp&15 != 0,
      'Can do 4.1 authentication': resp&16 != 0,
    }
  }

  # See: https://dev.mysql.com/doc/internals/en/character-set.html
  get_character_set(resp) {
    if self.charsets.contains(resp)
      return self.charsets[resp]
    return nil
  }

  # See: https://dev.mysql.com/doc/internals/en/status-flags.html#packet-Protocol::StatusFlags
  get_server_status(resp) {
    return {
      'SERVER_STATUS_IN_TRANS': resp&1 != 0, # transaction is active
      'SERVER_STATUS_AUTOCOMMIT': resp&2 != 0, # auto commit
      'SERVER_MORE_RESULTS_EXISTS': resp&3 != 0, # more results
      'Multi query - more resultsets': resp&4 != 0,
      'SERVER_STATUS_NO_GOOD_INDEX_USED': resp&5 != 0, # Bad index used
      'SERVER_STATUS_NO_INDEX_USED': resp&6 != 0, # No index used
      'SERVER_STATUS_CURSOR_EXISTS': resp&7 != 0, # Cursor exists
      'SERVER_STATUS_LAST_ROW_SENT': resp&8 != 0, # Last row sent
      'SERVER_STATUS_DB_DROPPED': resp&9 != 0, # database dropped
      'SERVER_STATUS_NO_BACKSLASH_ESCAPES': resp&10 != 0, # No backslash escapes
      'SERVER_SESSION_STATE_CHANGED': resp&11 != 0, # Session state changed
      'SERVER_QUERY_WAS_SLOW': resp&12 != 0, # Query was slow
      'SERVER_PS_OUT_PARAMS': resp&13 != 0, # PS Out Params
    }
  }

  # See: https://dev.mysql.com/doc/internals/en/capability-flags.html#packet-Protocol::CapabilityFlags
  get_server_extended_capabilities(resp) {
    return {
      'Multiple statements': resp&1 != 0,
      'Multiple results': resp&1 != 0,
      'PS Multiple results': resp&1 != 0,
      'Plugin Auth': resp&1 != 0,
      'Connect attrs': resp&1 != 0,
      'Plugin Auth LENENC Client Data': resp&1 != 0,
      'Client can handle expired passwords': resp&1 != 0,
      'Session variable tracking': resp&1 != 0,
      'Deprecate EOF': resp&1 != 0,
    }
  }

  encrypt_password(salt, password) {
    var bytes1 = convert.hex_to_bytes(hash.sha1(password))
    var concat = salt.to_bytes()
    concat += convert.hex_to_bytes(hash.sha1(hash.sha1(password)))
    var bytes2 = convert.hex_to_bytes(hash.sha1(concat))
    return bytes(util.zip(bytes1, bytes2, |x, y| { return x ^ y }))
  }

  capabilities_2_bytes(capabilities) {
    capabilities = ''.join(''.join(iters.map(capabilities.values(), |x| { return to_string(to_number(x)) })).to_list().reverse())
    capabilities = util.int_to_bytes(to_number('0b${capabilities}'), 2)
    return capabilities
  }
}


class LoginPacket < MysqlPacket {
  LoginPacket(handshake) {
    parent()
    self.handshake_info = handshake.parse()
  }

  create_packet(user, password, packet_number) {
    var packet = bytes(0)
    # client capabilities
    packet.extend(self.capabilities_2_bytes(self.client_capabilities))
    # extended client capabilities
    packet += self.capabilities_2_bytes(self.extended_client_capabilities)
    # max packet size -> 16777216
    var max_packet = util.int_to_bytes(16777216, 4)
    packet.extend(max_packet)
    # charset -> 33 (utf8_general_ci)
    packet.append(33)
    # 23 bytes are reserved
    packet.extend(bytes(23))
    # username (null byte end)
    packet.extend(user.to_bytes())
    packet.append(0)

    # password
    if password.length() > 0 {
      var salt = self.handshake_info['salt1'].to_bytes() + self.handshake_info['salt2'].to_bytes()
      var encrypted_pass = self.encrypt_password(salt.trim(), password)
      packet.append(encrypted_pass.length())
      packet.extend(encrypted_pass)
    } else {
      packet.append(0)
    }

    # authentication plugin
    packet.extend(self.handshake_info['authentication_plugin'].to_bytes())

    var pack = bytes(0)
    pack.append(packet.length())
    pack.extend(bytes(2))
    pack.append(packet_number)
    pack.extend(packet)

    return pack
  }
}


class HandshakePacket < MysqlPacket {
  parse() {
    return {
      'packet_name': 'HandshakePacket',
      'packet_length': Int(self, 3).next(), #self.next(3),
      'packet_number': Int(self, 1).next(), #self.next(1),
      'protocol': Int(self, 1).next(), #self.next(1),
      'server_version': Str(self, -1, 'null').next(),
      'connection_id': Int(self, 4).next(), #self.next(4),
      'salt1': Str(self, -1, 'null').next(),
      'server_capabilities': self.get_server_capabilities(Int(self, 2).next()),
      'server_language': self.get_character_set(Int(self, 1).next()),
      'server_status': self.get_server_status(Int(self, 2).next()),
      'server_extended_capabilities': self.get_server_extended_capabilities(Int(self, 2).next()),
      'authentication_plugin_length': Int(self, 1).next(),
      'unused': Int(self, 10).next(), #self.next(10, hex),
      'salt2': Str(self, -1, 'null').next(),
      'authentication_plugin': Str(self, -1, 'eof').next(),
    }
  }
}


class OkPacket < MysqlPacket {
  parse() {
    return {
      'packet_name': 'OkPacket',
      'packet_length': Int(self, 3).next(), #self.next(3),
      'packet_number': Int(self, 1).next(), #self.next(1),
      'header': hex(Int(self, 1).next()),
      'affected_rows': Int(self, 1).next(), #self.next(1),
      'last_insert_id': Int(self, 1).next(), #self.next(1),
      'server_status': self.get_server_status(Int(self, 2).next()),
      'warnings': Int(self, 2).next(),
    }
  }
}


class ErrorPacket < MysqlPacket {
  parse() {
    return {
      'packet_name': 'ErrPacket',
      'packet_length': Int(self, 3).next(), #self.next(3),
      'packet_number': Int(self, 1).next(), #self.next(1),
      'header': hex(Int(self, 1).next()), #self.next(1, hex),
      'error_code': Int(self, 2).next(), #self.next(2),
      'sql_state': Str(self, 6).next(),
      'error_message': Str(self, -1, 'eof').next(),
    }
  }
}


class EofPacket < MysqlPacket {
  parse() {
    return {
      'packet_name': 'EofPacket',
      'packet_length': Int(self, 3).next(),
      'packet_number': Int(self, 1).next(),
      'header': hex(Int(self, 1).next()),
      'auth_method_name': Str(self, -1, 'eof').next(),
    }
  }
}


class InitDBPacket < MysqlPacket {
  InitDBPacket(db) {
    parent()
    self.db = db
  }

  create_packet() {
    var packet = bytes(0)
    packet.append(self.commands.COM_INIT_DB)
    packet.extend(self.db.to_bytes())

    var pack = bytes(0)
    pack.append(packet.length())  # packet length
    pack.extend(bytes(2))
    pack.append(0)  # packet number
    pack.extend(packet)
    return pack
  }
}


class QuitPacket < MysqlPacket {
  create_packet() {
    var pack = bytes(0)
    pack.append(1)  # packet length
    pack.extend(bytes(2))
    pack.append(0)  # packet number
    pack.append(self.commands.COM_QUIT)
    return pack
  }
}


class QueryPacket < MysqlPacket {
  QueryPacket(sql) {
    parent()
    self.sql = sql
  }

  create_packet() {
    var packet = bytes(0)
    packet.append(self.commands.COM_QUERY)
    packet.extend(self.sql.to_bytes())

    var pack = bytes(0)
    pack.append(packet.length())  # packet length
    pack.extend(bytes(2))
    pack.append(0)  # packet number
    pack.extend(packet)
    return pack
  }
}


class QueryResponsePacket < MysqlPacket {
  parse() {
    var field_count = self.init()

    var ret = {
      packet_name: 'QueryResponsePacket',
      fields: [],
      rows: [],
    }

    for i in 0..field_count
      ret.fields.append(self.get_field())

    # skip first eof
    self.get_eof()

    var row
    while row = self.get_row(field_count)
      ret.rows.append(row)

    return ret
  }

  init() {
    var packet_length = Int(self, 3).next()
    var packet_number = Int(self, 1).next()
    var field_count = Int(self, 1).next()

    return field_count
  }

  get_eof() {
    return {
      'packet_length': Int(self, 3).next(),
      'packet_number': Int(self, 1).next(),
      'eof_marker': hex(Int(self, 1).next()),
      'warnings': Int(self, 2).next(),
      'server_status': self.get_server_status(Int(self, 2).next()),
    }
  }

  is_eof() {
    return self.next(1, 'int', true) == 0xFE
  }

  get_field() {
    var packet_length = Int(self, 3).next()
    var packet_number = Int(self, 1).next()
    var catalog = Str(self, -1, 'lenenc').next()
    var database = Str(self, -1, 'lenenc').next()
    var table = Str(self, -1, 'lenenc').next()
    var original_table = Str(self, -1, 'lenenc').next()
    var name = Str(self, -1, 'lenenc').next()
    var original_name = Str(self, -1, 'lenenc').next()
    var encoding = Int(self, 1).next()
    var charset_number = Int(self, 2).next()
    var length = Int(self, 4).next()
    var field_type = Int(self, 1).next()
    var flags = self.get_flags(Int(self, 2).next())
    var decimals = Int(self, 3).next()

    return {
      'database': database,
      'table': original_table,
      'name': name,
      'original_name': original_name,
      'length': length,
      'flags': flags,
      'field_type': field_type,
    }
  }

  get_flags(flags) {
    return {
      'not_null': flags & 1 != 0,
      'primary_key': flags & 2 != 0,
      'unique_key': flags & 3 != 0,
      'multiple_key': flags & 4 != 0,
      'blob': flags & 5 != 0,
      'unsigned': flags & 6 != 0,
      'zero_fill': flags & 7 != 0,
      'binary': flags & 8 != 0,
      'enum': flags & 9 != 0,
      'auto_increment': flags & 10 != 0,
      'timestamp': flags & 11 != 0,
      'set': flags & 12 != 0,
    }
  }

  get_row(field_count) {
    var packet_length = Int(self, 3).next()
    var packet_number = Int(self, 1).next()
    var ret = []

    for i in 0..field_count {
      if self.is_eof() break
      ret.append(Str(self, -1, 'lenenc').next())
    }

    return ret
  }
}


class ShowDatabasesPacket < QueryPacket {
  ShowDatabasesPacket() {
    parent('show databases')
  }

  parse(resp) {
    var response = QueryResponsePacket(resp)
    response = response.parse()
    return iters.map(response.rows, |x| { return x[0] })
  }
}
