module main

import smtp_server 
import api
import settings

fn main() {
    // Seeing if settings is able to be ran
    settings := settings.load()
    // Running the componets concurrently
    // Seeing if smtp server is enabled
    if settings.enabled.smtp_server {
        go smtp_server.start()
    }
    // Seeing if api is enabled
    if settings.enabled.api {
        go api.start()
    }
    // This is needed so it doesnt close
    for { }
}

