# See documentation: https://dev.mysql.com/doc/internals/en/integer.html
class Int {
  Int(packet, length, type) {
    if !length length = -1
    if !type type = 'fix'

    self.packet = packet
    self.length = length
    self.type = type
  }

  next() {
    # int<n>
    if self.type == 'fix' and self.length > 0
      return self.packet.next(self.length)
    # int<lenenc>
    if self.type == 'lenenc' {
      var byte = self.packet.next(1)
      if byte < 0xFB return self.packet.next(1)
      if byte == 0xFC return self.packet.next(2)
      if byte == 0xFD return self.packet.next(4)
      if byte == 0xFE return self.packet.next(8)
    }
  }
}


# See documentation: https://dev.mysql.com/doc/internals/en/string.html
class Str < Int {
  next() {
    # string<fix>
    if self.type == 'fix' and self.length > 0
      return self.packet.next(self.length)
    # string<lenenc>
    else if self.type == 'lenenc' {
      var length = self.packet.next(1)
      if length == 0x00 return ''
      else if length == 0xFB return 'NULL'
      else if length == 0xFF return 'undefined'
      return self.packet.next(length, 'str')
    }
    # string<var>
    else if self.type == 'var' {
      return self.packet.next(Int(self.packet, 'lenenc').next(), 'str')
    }
    # string<eof>
    else if self.type == 'eof' return self.packet.next(nil, 'str')
    # string<null> - null terminated strings
    else if self.type == 'null' {
      var strbytes = bytes(0), byte
      iter var i = 0; (byte = self.packet.next(1)) != 0x00; i++ {
        strbytes.append(byte)
      }
      return strbytes.to_string()
    }
  }
}
