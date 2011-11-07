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

  @now
  Scenario Outline: mysql options
    When I start rest-assured with -a mysql <options>
    Then database options should be:
      | dbname   | dbuser   | dbpass   | dbhost   | dbport   | dbencoding   | dbsocket   |
      | <dbname> | <dbuser> | <dbpass> | <dbhost> | <dbport> | <dbencoding> | <dbsocket> |

    Examples:
      | options                    | dbname       | dbuser | dbpass | dbhost | dbport | dbencoding | dbsocket        |
      |                            | rest_assured | root   |        |        |        |            |                 |
      | -d resta                   | resta        | root   |        |        |        |            |                 |
      | --database resta           | resta        | root   |        |        |        |            |                 |
      | -u bob                     | rest_assured | bob    |        |        |        |            |                 |
      | --dbuser bob               | rest_assured | bob    |        |        |        |            |                 |
      | --dbpass pswd              | rest_assured | root   | pswd   |        |        |            |                 |
      | --dbhost remote            | rest_assured | root   |        | remote |        |            |                 |
      | --dbport 5555              | rest_assured | root   |        |        | 5555   |            |                 |
      | --dbencoding utf16le       | rest_assured | root   |        |        |        | utf16le    |                 |
      | --dbsocket /tmp/mysql.sock | rest_assured | root   |        |        |        |            | /tmp/mysql.sock |

