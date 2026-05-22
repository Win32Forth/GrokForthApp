import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var consoleText = "=== GrokForth Ready ===\n\n"
    @State private var commandHistory: [String] = []
    @State private var historyIndex = -1
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextEditor(text: $consoleText)
            .font(.system(size: 16, design: .monospaced))
            .foregroundColor(.black)
            .background(Color.white)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .onChange(of: consoleText) { _, newValue in
                checkForCommandExecution(newValue)
            }
            .onKeyPress(.upArrow) {
                recallHistory(up: true)
                return .handled
            }
            .onKeyPress(.downArrow) {
                recallHistory(up: false)
                return .handled
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .onAppear {
                isFocused = true
            }
    }
    
    private func checkForCommandExecution(_ text: String) {
        let lines = text.components(separatedBy: .newlines)
        guard let lastLine = lines.last, lastLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let previousLine = lines.count >= 2 ? lines[lines.count - 2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
        
        if !previousLine.isEmpty && !previousLine.hasPrefix("===") {
            // Add to history
            if !commandHistory.contains(previousLine) {
                commandHistory.append(previousLine)
                if commandHistory.count > 16 {
                    commandHistory.removeFirst()
                }
            }
            
            let result = interpreter.evaluate(previousLine)
            
            DispatchQueue.main.async {
                if !result.isEmpty {
                    consoleText += result + "\n\n"
                } else {
                    consoleText += "\n"
                }
                historyIndex = -1
            }
        }
    }
    
    private func recallHistory(up: Bool) {
        guard !commandHistory.isEmpty else { return }
        
        if up {
            historyIndex = min(historyIndex + 1, commandHistory.count - 1)
        } else {
            historyIndex = max(historyIndex - 1, -1)
        }
        
        guard historyIndex >= 0 else { return }
        
        let selectedCommand = commandHistory[commandHistory.count - 1 - historyIndex]
        
        // Replace the current line carefully
        var lines = consoleText.components(separatedBy: .newlines)
        let lastIndex = lines.count - 1
        
        if lines[lastIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines[lastIndex - 1] = selectedCommand
        } else {
            lines[lastIndex] = selectedCommand
        }
        
        consoleText = lines.joined(separator: "\n")
    }
}
