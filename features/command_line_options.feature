Feature: command line options
  In order to run rest-assured in different configurations (db params, port, etc)
  As test developer
  I need a way to specify those configurations.

  Scenario Outline: specifying server port
    When I start rest-assured with <option>
    Then it should run on port <port>

    Examples:
      | option      | port |
      | -P 1234     | 1234 |
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
    Then database adapter should be mysql, db name should be "<dbname>", db user should be "<dbuser>", user password should be "<dbpass>" and db host should be "<dbhost>"

    Examples:
      | options          | dbname       | dbuser | dbpass | dbhost    |
      |                  | rest_assured | root   |        | localhost |
      | -d resta         | resta        | root   |        | localhost |
      | --database resta | resta        | root   |        | localhost |
      | -u bob           | rest_assured | bob    |        | localhost |
      | --user bob       | rest_assured | bob    |        | localhost |
      | -p pswd          | rest_assured | root   | pswd   | localhost |
      | --password pswd  | rest_assured | root   | pswd   | localhost |
      | -h remote        | rest_assured | root   |        | remote    |
      | --host remote    | rest_assured | root   |        | remote    |

