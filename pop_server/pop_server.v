module pop_server

import net
import os
import json
import settings

struct Email_file {
pub mut:
	files []string
    pop_files []string
}

struct Emailfile {
pub mut:
	size  int
	value string 
}

struct Emaillfile {
    pub:
        data string
}

pub fn start() {
	// Open port and start listening
	l := net.listen_tcp(110) or {
		panic(err)
	}
	// Waiting for requerst
	for {
		new_request := l.accept() or { continue }
		handle(new_request)
	}
}

fn handle(conn net.TcpConn) {
	// Getting settings
	settingsjson := settings.load()
	// Sending first command
	conn.write_str('+OK POP3 ${settingsjson.domain} v2003.83 server ready\n')
	// Creating a value thats set if user is logged in
	mut logged_in := false
	// Getting emails
	// TODO: have specific list for pop as pop deletes email as soon as request is made
	email_list_file_name := '$settingsjson.email_dir/emails.json'
	list_contents := os.read_file(email_list_file_name) or {
		error := 'Unable to read $settingsjson.email_dir/emails.json!'
		panic(error)
	}
	mut list := json.decode(Email_file, list_contents) or { panic(err) }
	// Getting files
	mut files := []Emailfile{}
	for filee in list.pop_files {
        data := os.read_file('${settingsjson.email_dir}/$filee') or { panic(err) }
        // decoding
        val := json.decode(Emaillfile, data) or { panic(err) } 
		files << Emailfile{
			size: os.file_size('$settingsjson.email_dir/$filee')
			value: val.data
        }
	}
    // Creating a blank array of indexes that will need to be deleted
    mut indexes := []int{}
	// Reading commands
	for {
		// Reading connection
		mut buf := []byte{len: 100}
		conn.read(mut buf) or {
			conn.close()
			println('conn closed')
			return
		}
		// Convert it to a string arrayt
		mut command := []string{}
		for byre in buf {
			command << byre.str()
		}
		// Handling commands
        // TODO: change to switch
		if command[0..4] == ['U','S','E','R'] {
			mut args := ''
			for arg in command[5..command.len] {
				args += arg
			}
			// Because we dont have usernames we just tell them to continue
			conn.write_str('+OK User name accepted\n')
		} else if command[0..4] == ['P','A','S','S'] {
			mut args := string{}
			for arg in command[5..command.len] {
                if arg == '\n' {
                    break
                } else if arg == '\r' {
                    continue
                } else {
                    args += arg.str()
                }
			}
			// I would prefer generate pop pass when server starts for the first time but for dev gonna just use one in settings
			if args == settingsjson.pop_pass {
				conn.write_str('+OK Welcome, ily\n')
				// Havintg person be logged in
				logged_in = true
			} else {
				conn.write_str('-ERR Bad password!\n')
			}
		} else if command[0..4] == ['S','T','A','T'] {
			// Telling how many emails
			mut size := 0
			for fi in files {
				size += fi.size
			}
			conn.write_str('+OK $list.files.len $size\n')
		} else if command[0..4] == ['L','I','S','T'] {
			conn.write_str('+OK Scan is\n')
			for i := 0; i < files.len; i++ {
				conn.write_str('$i ${files[i].size}\n')
			}
			conn.write_str('.\n')
		} else if command[0..4] == ['R','E','T','R'] {
            if logged_in {
                mut args := ''
			    for arg in command[5..command.len] {
				    args += arg
			    }           
                file := files[args.int()]
                conn.write_str('+OK ${file.size} octets\n')
                conn.write_str(file.value)
                conn.write_str('\n.\n')
          } else {
              conn.write_str('-ERR please login\n')
        }
        } else if command[0..4] == ['D','E','L','E'] {
            // TODO: make this work
            if logged_in {
                mut args := ''
                for arg in command[5..command.len] {
				    args += arg
			    }
                // Adding to list
                indexes << args.int()
                conn.write_str('+OK deleted \n')
            } else {
                conn.write_str('-ERR please login')
            }
        } else if command[0..4] == ['Q','U','I','T'] {
            conn.write_str('+OK bye!\n')
            conn.close()
            // Deleting deleted things
            mut i := indexes.len
            i--
            for i > 0 {
                list.pop_files.delete(indexes[i]) 
                i--
            }
            // If they want to delete 0 it wont work as the loop only goes to 1
            if 0 in indexes {
                list.pop_files.delete(0)
            }
            // Saving
            encoded := json.encode(list)
            os.write_file('${settingsjson.email_dir}/emails.json', encoded) 
        } else {
            conn.write_str('-ERR invalid command\n')
        }
	}
}
