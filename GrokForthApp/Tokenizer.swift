import Foundation

extension GrokForthInterpreter {
    
    func tokenize(_ input: String) -> [String] {
        var tokens: [String] = []
        var i = input.startIndex
        
        while i < input.endIndex {
            while i < input.endIndex && input[i].isWhitespace {
                i = input.index(after: i)
            }
            if i >= input.endIndex { break }
            
            // ( comment )
            if input[i] == "(" && (i == input.startIndex || input[input.index(before: i)].isWhitespace) {
                while i < input.endIndex && input[i] != ")" { i = input.index(after: i) }
                if i < input.endIndex { i = input.index(after: i) }
                continue
            }
            
            // \ comment
            if input[i] == "\\" && (i == input.startIndex || input[input.index(before: i)].isWhitespace) {
                break
            }
            
            // S" ..." , ." ..." and .( ... )
            if i < input.index(input.endIndex, offsetBy: -1) {
                let prefix = input[i...input.index(i, offsetBy: 1)]
                if prefix == "S\"" || prefix == ".\"" || prefix == ".(" {
                    let isS = prefix == "S\""
                    let isDotParen = prefix == ".("
                    
                    i = input.index(i, offsetBy: 2)   // skip two chars
                    
                    var content = ""
                    let terminator: Character = isDotParen ? ")" : "\""
                    
                    while i < input.endIndex && input[i] != terminator {
                        content.append(input[i])
                        i = input.index(after: i)
                    }
                    if i < input.endIndex { i = input.index(after: i) }
                    
                    let prefixChar = isS ? "S\"" : (isDotParen ? ".(" : ".\"")
                    tokens.append("\u{01}" + prefixChar + content)
                    continue
                }
            }
            
            // Regular word
            let start = i
            while i < input.endIndex && !input[i].isWhitespace {
                i = input.index(after: i)
            }
            let word = String(input[start..<i]).uppercased()
            tokens.append(word)
        }
        return tokens
    }
}
