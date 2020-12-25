module main

import smtp_server 
import os
import json

struct Settings {
    email_dir string [json:emailDir]
}

fn main() {
    // Loading settings
    filename := './settings.json'
    settings_file := os.read_file(filename) or { panic('Unable to find settings file! Please create settings.json') }
    settings_json := json.decode(Settings, settings_file) or {panic('Unable to parse settings')}
    smtp_server.start(settings_json.email_dir)
}

