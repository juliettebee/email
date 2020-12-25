////module server
//
//import net
//
//// Our structure for saving emails
//struct Email {
//    mut:
//        from string
//        to []string // To is an array as there can be multiple
//        data string
//}
//
//pub fn run() {
//    // Opens port 90
//	l := net.listen_tcp(25) or {
//		panic(err)
//	}
//    // Waiting for a request
//    for {
//        // Accepting request
//        // If it breaks just continue looping
//		new_conn := l.accept() or {
//			continue
//		}
//        // Handling connection
//        handle_connection(new_conn)
//	}
//}
//
//// Handling the connection
//fn handle_connection(connection net.TcpConn) {
//    // REading the input
//    // Creating the email
//    mut email := Email{}
//    // Seeing if we're getting data
//    mut getting_data := false
//    mut formatted := '' 
//    for {
//        mut buf := []byte{len: 100, init: 0}
//        read := connection.read(mut buf) or {
//            println('error reading')
//            break
//        }
////        // So the data we get is an array of bytes we need to convert it to a string
//        for str in buf {
//            formatted += str.str()
//        }
////        length_of_formatted := formatted.len
////        mut last_four := ''        
////        for i := 0; i < 3; i++ {
////            last_four += formatted[length_of_formatted - i - 1].str() 
////        }
//        // Now lets get the parts
////        for str in buf {
////            
////            println('str : $read')
////            str_as_string := str.str()
////            // Getting the headers
////            mut header := str_as_string[0].str() // Setting it to the first letter as the find between excludes first letter
////            header += str_as_string.find_between(str_as_string[0].str(), ':')// Getting the header
////            data := str_as_string.find_between(':', '')// Getting the data
////            println('header : $header \n data : $data')
////            match header {
////               'MAIL FROM' {
////                    email.from = data
////                } 
////                'RCPT TO' {
////                    email.to << data
////                }
////                'DATA' {
////                    getting_data = true
////                }
////                else {}
////            } 
////        }
//    }
////    // Getting the lines as an array
////    lines := formatted.split('\n')
////    println(lines)
//    println(formatted)
//}
