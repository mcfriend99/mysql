import io
import json
import ..app { * }

def test() {
  if !file('tests/config.json').exists()
    raise Exception('missing config file.')

  var config = json.decode(file('tests/config.json').read())

  var answers = {
    host: config.get('host', 'localhost'),
    port: to_number(config.get('port', 3306)),
    user: config.get('username', 'root'),
    pass: config.get('password', ''),
  }
  
  var mysql = Mysql(answers.host, answers.port, answers.user, answers.pass)
  catch {
    if !mysql.connect() {
      echo 'Could not login. Try again!'
    } else {
      echo 'Server version: MySQL ${mysql.info.server_version}'
      echo 'Connection ID: ${mysql.info.connection_id}'
      echo 'Server Language: ${mysql.info.server_language}'
      echo 'Fetching databases...'
      var databases = mysql.databases()

      echo ''
      for i, base in databases {
        echo '${i+1} => ${base}'
      }
      echo ''
      var db = to_number(io.readline('Choose a database from the list numbered 1 to ${databases.length()}: '))
      
      # align choosing item
      if db <= 0 db = 1
      else if db > databases.length() {
        db = resp.databases.length()
      }
      db--

      echo 'You\'ve selected database ${db} - ${databases[db]}'
      echo 'Switching to ${databases[db]}...'
      mysql.use_db(databases[db])
      echo ''
      
      var query
      while (query = io.readline('Blade MySQL> ')) != 'q' {
        catch {
          var resp = mysql.query(query.trim())
          if instance_of(resp, MysqlResult) {
            echo 'Done. Affected rows: ${resp.affected_rows}'
            if mysql.last_insert_id > 0 echo 'Last insert id: ${mysql.last_insert_id}'
          } else {
            echo TermTable(resp, {
              show_primary_key: true,
              show_length: true,
            }).render()
          }
        } as e 
        
        if e and e.type == 'MysqlException' {
          echo e.message
        }
      }

      mysql.close()
    }
  } as e 
  
  if e {
    echo e.message
    echo e.stacktrace
  }
}

test()
