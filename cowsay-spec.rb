describe "Cowsay Server" do
    it "should print a cow saying 'hi' when I send it the appropriate message" do
        response = `echo MESSAGE hi | nc localhost 4481`
        # I had to escape all of the backslashes to match the returned output.
        expected = <<EOF
STATUS 0

 ____
< hi >
 ----
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||

EOF
        response.should == expected
    end

    it "should print a status of 1 and an error message if I have a malformed message header" do
        response = `echo mESSAGE hi | nc localhost 4481`
        expected = <<EOF
STATUS 1

ERROR: Empty message
EOF
        response.should == expected
    end

    it "should print a non-zero status and appropriate error message if I pass a bogus cowfile name" do
        response = `echo "MESSAGE hi\nBODY bogus" | nc localhost 4481`
        expected = <<EOF
STATUS 2

ERROR cowsay: Could not find bogus cowfile!

EOF
        response.should == expected
    end

    it "should not execute shell commands passed as messages" do
        response = `echo "MESSAGE hi && sleep 5" | nc localhost 4481`
        expected = <<EOF
STATUS 0

 _______________
< hi && sleep 5 >
 ---------------
        \\   ^__^
         \\  (oo)\\_______
            (__)\\       )\\/\\
                ||----w |
                ||     ||

EOF
       response.should == expected 
    end

    it "should support non-default cowfiles" do
        response = `echo "MESSAGE hi\nBODY kitty" | nc localhost 4481`
        expected = <<EOF
STATUS 0

 ____
< hi >
 ----
     \\
      \\
       ("`-'  '-/") .___..--' ' "`-._
         ` *_ *  )    `-.   (      ) .`-.__. `)
         (_Y_.) ' ._   )   `._` ;  `` -. .-'
      _.. `--'_..-_/   /--' _ .' ,4
   ( i l ),-''  ( l i),'  ( ( ! .-'    

EOF
       response.should == expected 
    end

end


