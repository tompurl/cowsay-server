require 'socket'
require 'open3'

module CowSay
    class Server
        def initialize(port)
            # Create the underlying socket server
            @server = TCPServer.new(port)
            puts "Listening on port #{@server.local_address.ip_port}"
        end

        def start
            # TODO Currently this server can only accept one connection at at
            # time. Do I want to change that so I can process multiple requests
            # at once?
            Socket.accept_loop(@server) do |connection|
                handle(connection)
                connection.close
            end
        end

        # Find a value in a line for a given key 
        def find_value_for_key(key, document)

            retval = nil

            re = /^#{key} (.*)/
            md = re.match(document)
           
            if md != nil
                retval = md[1]
            end

            retval
        end

        # Parse the request that is sent by the client and convert it into a
        # hash table.
        def parse(request)
            commands = Hash.new
            commands[:error_flag] = false

            # TODO It's still possible to pass a non-message
            # value like -h or -l as a message. It would be nice
            # to sanitize your input.
            message_value = find_value_for_key("MESSAGE", request)
            if message_value == nil then
                commands[:message] = "ERROR: Empty message"
                commands[:error_flag] = true
            else
                commands[:message] = message_value
            end

            body_value = find_value_for_key("BODY", request)
            if body_value == nil then
                commands[:body] = "default"
            else
                commands[:body] = body_value
            end

            commands
        end

        def handle(connection)
            # TODO Read is going to block until EOF. I need to use something
            # different that will work without an EOF. 
            request = connection.read

            commands = parse(request)
            if commands[:error_flag] then
                # We got an error parsing the message, time to bail out.
                respond(connection, 1, commands[:message])
            else
                exit_status, output = process(commands)
                respond(connection, exit_status, output)
            end
        end

        def respond(connection, exit_status, message)
            connection.write <<EOF
STATUS #{exit_status}

#{message}
EOF
        end

        def process(commands)
            output = nil
            err_msg = nil
            exit_status = nil

            Open3.popen3('/usr/games/cowsay', '-f', commands[:body], commands[:message]) { |stdin, stdout, stderr, wait_thr|
                # TODO Do I need to wait for the process to complete?
                output = stdout.read
                err_msg = stderr.read
                exit_status = wait_thr.value.exitstatus
            }

            if exit_status != 0 then
                output = "ERROR #{err_msg}"
            end

            return exit_status, output
        end
    end
end

server = CowSay::Server.new(4481)
server.start
