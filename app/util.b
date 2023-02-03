import convert

def bytes_to_hex(bytes) {
  var result = []
  for byte in bytes {
    result.append(convert.decimal_to_hex(byte).lpad(2, '0'))
  }
  return ''.join(result)
}

def int_from_bytes(bytes) {
  var data = bytes.to_list().reverse()
  var result = []
  for byte in data {
    result.append(convert.decimal_to_hex(byte).lpad(2, '0'))
  }
  return to_number('0x${''.join(result)}')
}

def int_to_bytes(n, l) {
  var bts = convert.hex_to_bytes(convert.decimal_to_hex(n))
  if l and bts.length() < l {
    bts.extend(bytes(l - bts.length()))
  }
  return bts
}

def zip(a, b, fn) {
  var len = a.length() > b.length() ? a.length() : b.length()

  var result = []
  iter var i = 0; i < len; i++ {
    result.append(fn(a[i], b[i]))
  }

  return result
}
