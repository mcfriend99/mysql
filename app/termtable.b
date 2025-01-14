import .result { 
  MysqlResultSet 
}


/**
 * TermTable class implements a simple terminal based table that can be used to 
 * display MysqlResultSet in CLI based applications.
 */
class TermTable {
  var _items = []
  var _cell_widths = []

  /**
   * TermTable constructor
   * 
   * @param MysqlResultSet result A valid resultset returned from Mysql::query()
   * @param dictionary options    Used for configuring how TermTable displays data.
   * 
   * The options dictionary can contain one or more of the following entries.
   * 
   * - bool `show_header` [default: true]
   * - bool `show_primary_key` [default: false]
   * - bool `show_foreign_key` [default: false]
   * - bool `show_length`  [default: false]
   * - string `primary_key_text` [default: `+PK`]
   * - string `foriegn_key_text` [default: `+FK`]
   */
  TermTable(result, options) {
    if !instance_of(result, MysqlResultSet)
      raise Exception('instance of MysqlResultSet expected')
    if !options options = {}

    self._show_header = options.get('show_header', true)
    var show_pk = options.get('show_primary_key', false)
    var show_fk = options.get('show_foreign_key', false)
    var show_length = options.get('show_length', false)
    var pk_indicator = options.get('primary_key_text', '+PK')
    var fk_indicator = options.get('foriegn_key_text', '+FK')

    if self._show_header {
      var fields = result.fields.map(@(x) { 
        var name = show_length ? '${x.name}(${x.length})' : x.name

        if x.flags.primary_key and show_pk
          return '${name} ${pk_indicator}'
        if x.flags.multiple_key and show_fk
          return '${name} ${fk_indicator}'

        return name
      })

      self._add_line(fields)
    }
    for row in result.rows self._add_line(row)
  }
  
  _add_line(item) {
    if is_list(item) {
      self._items.append(item)
    }
    return self
  }

  _get_cell_widths() {
    for item in self._items {
      iter var i = 0; i < item.length(); i++ {
        var it = to_string(item[i])
        if i <= self._cell_widths.length() - 1 {
          if it.length() > self._cell_widths[i]
            self._cell_widths[i] = it.length()
        } else {
          self._cell_widths.append(it.length())
        }
      }
    }
  }

  _get_overline(item) {
    var overline = '+'
    iter var i = 0; i < item.length(); i++ {
      overline += ('-' * (self._cell_widths[i] + 2)) + '+'
    }
    return overline
  }

  _render_headers() {
    if self._show_header {
      var header = self._items[0]
      var txt_line = '|' + '|'.join (header.map(@(x, i) {
        return ' ${x}'.rpad(self._cell_widths[i] + 2)
      })) + '|'

      return self._get_overline(header) + '\r\n' + txt_line
    }
    return ''
  }

  _render_body() {
    var start = self._show_header ? 1 : 0
    var overline = self._get_overline(self._items[0])

    if self._items.length() >= start + 1 {
      var lines = []

      for item in self._items[start,] {
        lines.append('|' + '|'.join (item.map(@(x, i) {
          x = to_string(x)
          return ' ${x}'.rpad(self._cell_widths[i] + 2)
        })) + '|')
      }

      return overline + '\r\n' + '\r\n'.join(lines) + '\r\n' + overline
    }
    return overline
  }

  /**
   * Renders the table to string.
   * 
   * @returns string
   */
  render() {
    self._get_cell_widths()
    return self._render_headers() + '\r\n' + self._render_body()
  }
}
