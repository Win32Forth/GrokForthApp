import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var consoleText = "=== GrokForth Ready ===\n\n"
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextEditor(text: $consoleText)
            .font(.system(size: 14, design: .monospaced))
            .foregroundColor(.black)
            .background(Color.white)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .onChange(of: consoleText) { newValue in
                processInput(newValue)
            }
            .frame(minWidth: 800, minHeight: 600)
            .onAppear {
                isFocused = true
            }
    }
    
    private func processInput(_ newText: String) {
        let lines = newText.components(separatedBy: .newlines)
        guard let lastLine = lines.last else { return }
        
        // If user just pressed Enter on a new line
        if lastLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let previousLine = lines.count >= 2 ? lines[lines.count - 2] : ""
            
            let command = previousLine.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !command.isEmpty && !command.hasPrefix("===") {
                // Execute the command
                let result = interpreter.evaluate(command)
                
                // Append result safely
                DispatchQueue.main.async {
                    if !result.isEmpty {
                        consoleText += result + "\n\n"
                    } else {
                        consoleText += "\n"
                    }
                }
            }
        }
    }
}
