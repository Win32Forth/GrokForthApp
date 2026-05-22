import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var consoleText = "=== GrokForth Ready ===\n\n"
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $consoleText)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(.black)
                .background(Color.white)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .onSubmit {
                    processLastLine()
                }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            isFocused = true
        }
    }
    
    private func processLastLine() {
        let lines = consoleText.components(separatedBy: .newlines)
        guard let lastLine = lines.last?.trimmingCharacters(in: .whitespacesAndNewlines),
              !lastLine.isEmpty else { return }
        
        // Only process lines that start with "Forth>"
        if lastLine.hasPrefix("Forth>") {
            let command = lastLine.dropFirst(6).trimmingCharacters(in: .whitespacesAndNewlines)
            
            let result = interpreter.evaluate(String(command))
            
            if !result.isEmpty {
                consoleText += result + "\n"
            }
            consoleText += "\n"
        }
    }
}
