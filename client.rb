require 'socket'

module CowSay
    class Client
        class << self
            attr_accessor :host, :port
        end

        # Convert our arguments into a document that we can send to the cowsay
        #>server.
        #
        # Options:
        #   message: The message that you want the cow to say
        #   body: The cowsay body that you want to use
        def self.say(options)

            if !options[:message]
                raise "ERROR: Missing message argument"
            end
             
            if !options[:body]
                options[:body] = "default"
            end

            request <<EOF
MESSAGE #{options[:message]}
BODY    #{options[:body]}
EOF
        end

        def self.request(string)
            # Create a new connection for each operation
            @client = TCPSocket.new(host, port)
            @client.write(string)

            # Send EOF after writing the request
            @client.close_write

            # Read until EOF to get the response
            @client.read
        end
    end
end

CowSay::Client.host = 'localhost'
CowSay::Client.port = 4481

puts CowSay::Client.say message: 'this is cool!'
puts CowSay::Client.say message: 'This SUCKS!', body: 'beavis.zen'
puts CowSay::Client.say message: 'Moshi moshi!', body: 'hellokitty'
