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
    
    internal var wordOrder: [String] = []           // definition order for FORGET
    public var clearScreenRequested = false
    
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
    
    internal func push(_ value: Int) {
        dataStack.append(value)
    }
    
    internal func pop() throws -> Int {
        guard !dataStack.isEmpty else { throw ForthError.stackUnderflow }
        return dataStack.removeLast()
    }
    
    // MARK: - Reset and Special Words
    
    /// Full interpreter reset (used by RESET word)
    func reset() {
        dataStack.removeAll()
        returnStack.removeAll()
        dictionary.removeAll()
        wordOrder.removeAll()
        constants.removeAll()
        memory = [0: 10]
        nextAddress = 1000
        base = 10
        clearScreenRequested = true
        outputBuffer = ""
    }
    
    /// ANS Forth style FORGET: removes the word and all subsequently defined words
    func forget(_ name: String) throws {
        let upperName = name.uppercased()
        
        guard let index = wordOrder.firstIndex(of: upperName) else {
            throw ForthError.unknownWord(upperName)
        }
        
        // Remove this word and everything defined after it
        let toRemove = Array(wordOrder[index...])
        
        for word in toRemove {
            dictionary.removeValue(forKey: word)
            constants.removeValue(forKey: word)
        }
        
        wordOrder.removeSubrange(index...)
    }
}

// MARK: - Internal Types
internal struct CompileState {
    let name: String
    var tokens: [String] = []
}
