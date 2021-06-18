import Foundation

let arguments = CommandLine.arguments

if arguments.count < 2 {
    print("\(arguments[0]) [Path to email storage folder]")
}
