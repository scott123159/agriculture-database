require 'mysql2'
module Database
    class Mysql
        def initialize(hostname, username, password, database)
            @cnx = Mysql2::Client.new(
                :host => hostname,
                :username => username,
                :password => password,
                :database => database,
            )
            @cnx.close()
        end
    end
end