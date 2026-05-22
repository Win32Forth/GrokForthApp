import Foundation

extension GrokForthInterpreter {
    func handleSpecial(_ token: String) throws {
        switch token {
        case "CLS": outputBuffer += "\u{01}CLS"
        case "RESET": /* reset interpreter state */ break
        case "PSEUDODUMP": outputBuffer += "\n" + pseudodump()
        case "FORGET": /* basic implementation */ break
        default: break
        }
    }
}
