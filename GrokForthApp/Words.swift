import Foundation

extension GrokForthInterpreter {
    
    // Single source of truth for primitive word documentation
    private static let primitives: [(name: String, stack: String, desc: String)] = [
        // Arithmetic
        ("+",       "( n1 n2 -- n )",     "addition"),
        ("-",       "( n1 n2 -- n )",     "subtraction"),
        ("*",       "( n1 n2 -- n )",     "multiplication"),
        ("/",       "( n1 n2 -- quot )",  "division"),
        ("MOD",     "( n1 n2 -- rem )",   "remainder"),
        ("1+",      "( n -- n+1 )",       "increment"),
        ("1-",      "( n -- n-1 )",       "decrement"),
        ("ABS",     "( n -- u )",         "absolute value"),
        ("NEGATE",  "( n -- -n )",        "negate"),
        ("MIN",     "( n1 n2 -- min )",   "minimum"),
        ("MAX",     "( n1 n2 -- max )",   "maximum"),
        
        // Stack
        ("DUP",     "( n -- n n )",       "duplicate"),
        ("DROP",    "( n -- )",           "discard top"),
        ("SWAP",    "( a b -- b a )",     "swap top two"),
        ("OVER",    "( a b -- a b a )",   "copy second"),
        ("ROT",     "( a b c -- b c a )", "rotate"),
        ("-ROT",    "( a b c -- c a b )", "reverse rotate"),
        ("NIP",     "( a b -- b )",       "remove second"),
        ("TUCK",    "( a b -- b a b )",   "tuck top under second"),
        
        // Memory
        ("@",       "( addr -- n )",      "fetch cell"),
        ("!",       "( n addr -- )",      "store cell"),
        ("+!",      "( n addr -- )",      "add to cell"),
        ("C@",      "( addr -- byte )",   "fetch byte"),
        ("C!",      "( byte addr -- )",   "store byte"),
        
        // Output
        (".",       "( n -- )",           "print number"),
        (".S",      "( -- )",             "print data stack"),
        ("CR",      "( -- )",             "carriage return"),
        ("SPACE",   "( -- )",             "print space"),
        ("SPACES",  "( n -- )",           "print n spaces"),
        
        // Control Flow
        ("DO",      "( limit start -- )", "start counted loop"),
        ("LOOP",    "( -- )",             "end DO loop"),
        ("UNLOOP",  "( -- )",             "discard loop parameters"),
        ("LEAVE",   "( -- )",             "exit loop early"),
        ("?DO",     "( limit start -- )", "DO loop that skips if start == limit"),
        ("I",       "( -- n )",           "current loop index"),
        ("BEGIN",   "( -- )",             "start indefinite loop"),
        ("UNTIL",   "( flag -- )",        "loop while false"),
        ("AGAIN",   "( -- )",             "infinite loop"),
        ("IF",      "( flag -- )",        "conditional branch"),
        ("ELSE",    "( -- )",             "else branch"),
        ("THEN",    "( -- )",             "end IF"),
        
        // Dictionary & System
        ("WORDS",   "( -- )",             "list all words"),
        ("SEE",     "( -- name )",        "decompile word"),
        ("HELP",    "( -- ) name",        "show help for a word"),
        ("VARIABLE","( -- ) name",        "create variable"),
        ("CONSTANT","( n -- ) name",      "create constant"),
        ("VALUE",   "( n -- ) name",      "create value"),
 
        ("AND",     "( n1 n2 -- n )",     "bitwise and"),
        ("OR",      "( n1 n2 -- n )",     "bitwise or"),
        ("XOR",     "( n1 n2 -- n )",     "bitwise xor"),
        ("INVERT",  "( n -- ~n )",        "bitwise invert"),
        ("LSHIFT",  "( n bits -- n )",    "left shift"),
        ("RSHIFT",  "( n bits -- n )",    "right shift"),
        ("TRUE",    "( -- -1 )",          "true flag"),
        ("FALSE",   "( -- 0 )",           "false flag"),
        ("DEPTH",   "( -- n )",           "stack depth"),
        ("WITHIN",  "( n lo hi -- flag )","n within lo..hi"),
        
        // Base
        ("HEX",     "( -- )",             "set base 16"),
        ("DECIMAL", "( -- )",             "set base 10"),
        ("OCTAL",   "( -- )",             "set base 8"),
        ("BINARY",  "( -- )",             "set base 2"),
        ("BASE",    "( -- addr )",        "push base address")
    ]
    
    private static let primitiveLookup: [String: (stack: String, desc: String)] = {
        Dictionary(uniqueKeysWithValues: primitives.map { 
            ($0.name, (stack: $0.stack, desc: $0.desc)) 
        })
    }()
    
    func listWords() {
        // Built-in words in alphabetical order
        let builtinNames = Self.primitives.map { $0.name }.sorted()
        
        // User-defined words in the order they were compiled (definition order)
        let userNames = wordOrder
        
        // Internals first (alpha), then user words (compile order) at the end
        let allWords = builtinNames + userNames
        
        outputBuffer += allWords.joined(separator: " ") + "\n"
    }
    
    /// Displays help information for a single word (used by HELP <word>)
    func help(for word: String) {
        let upper = word.uppercased()
        
        if let info = Self.primitiveLookup[upper] {
            outputBuffer += "\n\(upper)  \(info.stack)  \(info.desc)\n\n"
            return
        }
        
        if dictionary[upper] != nil {
            outputBuffer += "\n\(upper)  ( -- )  user-defined\n\n"
            appendDefinition(of: upper)
            outputBuffer += "\n"
            return
        }
        
        outputBuffer += "\(upper) ?\n"
    }
}
