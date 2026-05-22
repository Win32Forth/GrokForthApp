import Foundation

extension GrokForthInterpreter {
    
    func processTokens2(_ tokens: [String]) throws {
        var ip = 0
        while ip < tokens.count {
            let token = tokens[ip]
            
            // COMPILE MODE
            if compileState != nil {
                if token == ";" {
                    try endColonDefinition()
                    ip += 1
                    continue
                } else if token != ":" {
                    compileState?.tokens.append(token)
                }
                ip += 1
                continue
            }
            
            // INTERPRET MODE
            ip += 1
            
            if token == ":" { try startColonDefinition(tokens, &ip); continue }
            if token == "VARIABLE" { try defineVariable(tokens, &ip); continue }
            if token == "CONSTANT" || token == "VALUE" { try defineConstant(tokens, &ip); continue }
            
            // Memory
            if token == "@" { let addr = try pop(); push(memory[addr] ?? 0); continue }
            if token == "!" { let addr = try pop(); let val = try pop(); memory[addr] = val; continue }
            if token == "+!" { let n = try pop(); let addr = try pop(); memory[addr] = (memory[addr] ?? 0) + n; continue }
            
            if token == ".S" {
                outputBuffer += "<\(dataStack.count)> \(dataStack.reversed().map(String.init).joined(separator: " ")) "
                continue
            }
            
            if let num = Int(token, radix: base) { push(num); continue }
            if let body = dictionary[token] { try runUserWord(body); continue }
            
            switch token {
            // Arithmetic
            case "+": let b = try pop(); let a = try pop(); push(a + b)
            case "-": let b = try pop(); let a = try pop(); push(a - b)
            case "*": let b = try pop(); let a = try pop(); push(a * b)
            case "/": let b = try pop(); let a = try pop(); push(b != 0 ? a / b : 0)
            case "MOD": let b = try pop(); let a = try pop(); push(b != 0 ? a % b : 0)
            case "1+": let v = try pop(); push(v + 1)
            case "1-": let v = try pop(); push(v - 1)
            case "ABS": let v = try pop(); push(abs(v))
            case "NEGATE": let v = try pop(); push(-v)
                
            // Stack
            case "DUP": let v = try pop(); push(v); push(v)
            case "DROP": _ = try pop()
            case "SWAP": let b = try pop(); let a = try pop(); push(b); push(a)
            case "OVER": let b = try pop(); let a = try pop(); push(a); push(b); push(a)
            case "ROT": let c = try pop(); let b = try pop(); let a = try pop(); push(b); push(c); push(a)
                
            // Comparisons
            case "=": let b = try pop(); let a = try pop(); push(a == b ? -1 : 0)
            case "<>": let b = try pop(); let a = try pop(); push(a != b ? -1 : 0)
            case "<": let b = try pop(); let a = try pop(); push(a < b ? -1 : 0)
            case ">": let b = try pop(); let a = try pop(); push(a > b ? -1 : 0)
            case "<=": let b = try pop(); let a = try pop(); push(a <= b ? -1 : 0)
            case ">=": let b = try pop(); let a = try pop(); push(a >= b ? -1 : 0)
            case "0=": push(try pop() == 0 ? -1 : 0)
            case "0<": push(try pop() < 0 ? -1 : 0)
            case "0>": push(try pop() > 0 ? -1 : 0)
                
            // Output
            case ".": let v = try pop(); outputBuffer += "\(v) "
                
            // Loops
            case "DO":
                let start = try pop()
                let limit = try pop()
                returnStack.append(ip)
                returnStack.append(limit)
                returnStack.append(start)
                continue
            case "LOOP":
                guard returnStack.count >= 3 else { throw ForthError.stackUnderflow }
                var index = returnStack.removeLast()
                let limit = returnStack.removeLast()
                let jumpAddr = returnStack.removeLast()
                index += 1
                if index < limit {
                    returnStack.append(jumpAddr)
                    returnStack.append(limit)
                    returnStack.append(index)
                    ip = jumpAddr
                }
                continue
            case "I":
                guard returnStack.count >= 3 else { throw ForthError.stackUnderflow }
                push(returnStack[returnStack.count - 1])
                continue
                
            case "WORDS": listWords()
            case "SEE": try seeWord(tokens, &ip)
                
            default:
                throw ForthError.unknownWord(token)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func startColonDefinition(_ tokens: [String], _ ip: inout Int) throws {
        guard ip < tokens.count else { throw ForthError.unknownWord(":") }
        let name = tokens[ip]
        ip += 1
        compileState = CompileState(name: name, tokens: [])
        logger?("COMPILE: \(name)")
    }
    
    private func endColonDefinition() throws {
        guard let state = compileState else { return }
        dictionary[state.name] = state.tokens
        logger?("COMPILED \(state.name)")
        compileState = nil
    }
    
    private func defineVariable(_ tokens: [String], _ ip: inout Int) throws {
        guard ip < tokens.count else { return }
        let name = tokens[ip]
        ip += 1
        let addr = nextAddress
        memory[addr] = 0
        nextAddress += 1
        dictionary[name] = [String(addr)]
    }
    
    private func defineConstant(_ tokens: [String], _ ip: inout Int) throws {
        guard ip < tokens.count else { return }
        let name = tokens[ip]
        ip += 1
        let value = try pop()
        constants[name] = value
    }
    
    private func runUserWord(_ body: [String]) throws {
        try processTokens(body)
    }
    
    //private func listWords() {
    //    let allWords = dictionary.keys.sorted()
    //    outputBuffer += "Words: " + allWords.joined(separator: " ") + "\n"
    //}
    
    private func seeWord(_ tokens: [String], _ ip: inout Int) throws {
        guard ip < tokens.count else { return }
        let name = tokens[ip].uppercased()
        ip += 1
        if let body = dictionary[name] {
            outputBuffer += ": \(name) \(body.joined(separator: " ")) ;\n"
        } else {
            outputBuffer += "\(name) ?\n"
        }
    }
}
