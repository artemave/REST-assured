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

  @now
  Scenario Outline: sqlite options
    When I start rest-assured with <options>
    Then database adapter should be <adapter> and db file should be <dbfile>

    Examples:
      | options                  | adapter | dbfile            |
      |                          | sqlite  | ./rest-assured.db |
      | -d /tmp/ratest.db        | sqlite  | /tmp/ratest.db    |
      | --database /tmp/resta.db | sqlite  | /tmp/resta.db     |
