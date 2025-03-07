# mysql

A MySQL client implemented in pure Blade.

### Package Information

- **Name:** mysql
- **Version:** 1.0.0
- **Homepage:** https://github.com/mcfriend99/mysql
- **Tags:** mysql, database, sql, mysql-client, db
- **Author:** Richard Ore <eqliqandfriends@gmail.com>
- **License:** MIT

## Installation

You can install the mysql library with [Nyssa package manager](https://nyssa.bladelang.com)

```
nyssa install mysql
```

## Documentation

Online documentation is available at [mcfriend99.github.io/mysql](https://mcfriend99.github.io/mysql/).

## Important Notice

- The library currently only supports MySQL servers with `native_password` authentication method enabled. This covers all MySQL versions 5.7 and below but may need to be enabled for higher MySQL versions. This library has been tested up to MySQL server 9.0.1.
- There is no support for prepared statements yet.