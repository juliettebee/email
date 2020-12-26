module main

import smtp_server 
import api

fn main() {
    // Running the componets in other threads
    go smtp_server.start()
    go api.start()
    // This is needed so it doesnt close
    for { }
}

