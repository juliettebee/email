module main

import smtp_server 
import api
import settings

fn main() {
    // Seeing if settings is able to be ran
    _ := settings.load()
    // Running the componets in other threads
    go smtp_server.start()
    go api.start()
    // This is needed so it doesnt close
    for { }
}

