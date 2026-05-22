import Foundation

public class GrokForthInterpreter {
    
    internal var dataStack: [Int] = []
    internal var returnStack: [Int] = []        // for loops
    
    internal var dictionary: [String: [String]] = [:]
    internal var constants: [String: Int] = [:]
    internal var memory: [Int: Int] = [0: 10]
    internal var nextAddress = 1000
    internal var base = 10
    internal var outputBuffer = ""
    
    internal var compileState: CompileState? = nil
    internal let logger: ((String) -> Void)?
    
    public init(logger: ((String) -> Void)? = nil) {
        self.logger = logger
    }
    
    public func evaluate(_ input: String) -> String {
        outputBuffer = ""
        let tokens = tokenize(input)
        guard !tokens.isEmpty else { return " ok" }
        
        do {
            try processTokens(tokens)
            let result = outputBuffer.isEmpty ? " ok" : outputBuffer + " ok"
            outputBuffer = ""
            return result
        } catch let error as ForthError {
            dataStack.removeAll()
            returnStack.removeAll()
            return "\(error.errorDescription)\n ok"
        } catch {
            dataStack.removeAll()
            returnStack.removeAll()
            return "Error\n ok"
        }
    }
    
    public func pseudodump() -> String {
        buildPseudoDump()
    }
    
    internal func push(_ value: Int) {
        dataStack.append(value)
    }
    
    internal func pop() throws -> Int {
        guard !dataStack.isEmpty else { throw ForthError.stackUnderflow }
        return dataStack.removeLast()
    }
}

// MARK: - Internal Types
internal struct CompileState {
    let name: String
    var tokens: [String] = []
}
