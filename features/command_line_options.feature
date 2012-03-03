Feature: command line options
  In order to run rest-assured in different configurations (db params, port, etc)
  As test developer
  I need a way to specify those configurations.

  Scenario Outline: specifying server port
    When I start rest-assured with <option>
    Then it should run on port <port>

    Examples:
      | option      | port |
      | -p 1234     | 1234 |
      | --port 1235 | 1235 |
      |             | 4578 |

  Scenario Outline: specifying log file
    When I start rest-assured with <option>
    Then the log file should be <logfile>

    Examples:
      | option                   | logfile               |
      | -l /tmp/rest-assured.log | /tmp/rest-assured.log |
      | --logfile ./test.log     | ./test.log            |
      |                          | ./rest-assured.log    |

  Scenario Outline: sqlite options
    When I start rest-assured with <options>
    Then database adapter should be sqlite and db file should be <dbfile>

    Examples:
      | options                  | dbfile            |
      |                          | ./rest-assured.db |
      | -d /tmp/ratest.db        | /tmp/ratest.db    |
      | --database /tmp/resta.db | /tmp/resta.db     |

  Scenario Outline: mysql options
    When I start rest-assured with -a mysql <options>
    Then database options should be:
      | dbname   | dbuser   | dbpass   | dbhost   | dbport   | dbencoding   | dbsocket   | adapter    |
      | <dbname> | <dbuser> | <dbpass> | <dbhost> | <dbport> | <dbencoding> | <dbsocket> | <adapter> |

    Examples:
      | options                    | dbname       | dbuser | dbpass | dbhost | dbport | dbencoding | dbsocket        | adapter |
      |                            | rest_assured | root   |        |        |        |            |                 | mysql2  |
      | -d resta                   | resta        | root   |        |        |        |            |                 | mysql2  |
      | --database resta           | resta        | root   |        |        |        |            |                 | mysql2  |
      | -u bob                     | rest_assured | bob    |        |        |        |            |                 | mysql2  |
      | --dbuser bob               | rest_assured | bob    |        |        |        |            |                 | mysql2  |
      | --dbpass pswd              | rest_assured | root   | pswd   |        |        |            |                 | mysql2  |
      | --dbhost remote            | rest_assured | root   |        | remote |        |            |                 | mysql2  |
      | --dbport 5555              | rest_assured | root   |        |        | 5555   |            |                 | mysql2  |
      | --dbencoding utf16le       | rest_assured | root   |        |        |        | utf16le    |                 | mysql2  |
      | --dbsocket /tmp/mysql.sock | rest_assured | root   |        |        |        |            | /tmp/mysql.sock | mysql2  |

  Scenario Outline: postgresql options
    When I start rest-assured with -a postgresql <options>
    Then database options should be:
      | dbname   | dbuser   | dbpass   | dbhost   | dbport   | dbencoding   | adapter   |
      | <dbname> | <dbuser> | <dbpass> | <dbhost> | <dbport> | <dbencoding> | <adapter> |

    Examples:
      | options              | dbname       | dbuser | dbpass | dbhost | dbport | dbencoding | adapter    |
      |                      | rest_assured | root   |        |        |        |            | postgresql |
      | -d resta             | resta        | root   |        |        |        |            | postgresql |
      | --database resta     | resta        | root   |        |        |        |            | postgresql |
      | -u bob               | rest_assured | bob    |        |        |        |            | postgresql |
      | --dbuser bob         | rest_assured | bob    |        |        |        |            | postgresql |
      | --dbpass pswd        | rest_assured | root   | pswd   |        |        |            | postgresql |
      | --dbhost remote      | rest_assured | root   |        | remote |        |            | postgresql |
      | --dbport 5555        | rest_assured | root   |        |        | 5555   |            | postgresql |
      | --dbencoding utf16le | rest_assured | root   |        |        |        | utf16le    | postgresql |

  Scenario Outline: use ssl option
    When I start rest-assured with <option>
    Then rest-assured should "<ssl>"

    Examples:
      | option | ssl |
      |        | false   |
      | --ssl  | true    |

  Scenario Outline: specifying ssl options 
    When I start rest-assured with <option>
    Then ssl certificate used should be "<ssl_cert>" and ssl key should be "<ssl_key>"

    Examples:
      | option                  | ssl_cert        | ssl_key        |
      | -c /tmp/mycert.crt      | /tmp/mycert.crt | DEFAULT_KEY    |
      | --ssl_cert ./mycert.crt | ./mycert.crt    | DEFAULT_KEY    |
      |                         | DEFAULT_CERT    | DEFAULT_KEY    |
      | -k /tmp/mykey.key       | DEFAULT_CERT    | /tmp/mykey.key |
      | --ssl_key ./mykey.key   | DEFAULT_CERT    | ./mykey.key    |
