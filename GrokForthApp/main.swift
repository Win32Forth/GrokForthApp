//
//  main.swift
//  GrokForth
//
//  Created by Thomas Zimmer mini on 5/13/26.
//
//import GrokForthEngine
import Foundation

let forth = GrokForthInterpreter { print("🔍 \( $0 )") }

print("=== GrokForth — Native Apple Forth Interpreter ===")

while true {
    print("> ", terminator: "")
    guard let line = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines),
          !line.isEmpty else { continue }
    
    if ["quit", "exit"].contains(line.lowercased()) {
        break
    }
    
    let result = forth.evaluate(line)
    print(result)
}
