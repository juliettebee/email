module settings

import os 
import json

struct Settingsjson {
    pub:
        email_dir string [json:emailDir]
        webhook string
        api_key string
        domain string
        enabled Settingsenabled [json:enabledModules]
        pop_pass string [json:popPass
} 

struct Settingsenabled {
    pub:
        smtp_server bool [json:smtpServer]
        api bool
        pop string
}

pub fn load() Settingsjson {
    // Loading settings
    filename := './settings.json'
    settings_file := os.read_file(filename) or { panic('Unable to find settings file! Please create settings.json') }
    settings_json := json.decode(Settingsjson, settings_file) or {panic('Unable to parse settings')}
    return settings_json
}
