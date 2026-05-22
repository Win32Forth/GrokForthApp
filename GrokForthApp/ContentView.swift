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
            // Force better scroll behavior
            .scrollDisabled(false)
    }
    
    private func processInput(_ newText: String) {
        let lines = newText.components(separatedBy: .newlines)
        guard let lastLine = lines.last else { return }
        
        if lastLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let previousLine = lines.count >= 2 ? lines[lines.count - 2] : ""
            let command = previousLine.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !command.isEmpty && !command.hasPrefix("===") {
                let result = interpreter.evaluate(command)
                
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
