import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var consoleText = "=== GrokForth Ready ===\n\n"
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextEditor(text: $consoleText)
            .font(.system(size: 16, design: .monospaced))
            .foregroundColor(.black)
            .background(Color.white)
            .scrollContentBackground(.hidden)
            .focused($isFocused)
            .onChange(of: consoleText) { oldValue, newValue in
                processLastLine(newValue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .onAppear {
                isFocused = true
            }
    }
    
    private func processLastLine(_ newText: String) {
        let lines = newText.components(separatedBy: .newlines)
        guard let lastLine = lines.last?.trimmingCharacters(in: .whitespacesAndNewlines) else { return }
        
        // Only process if user just pressed Return (empty last line)
        if lastLine.isEmpty && lines.count >= 2 {
            let previousLine = lines[lines.count - 2].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !previousLine.isEmpty && !previousLine.hasPrefix("===") {
                let result = interpreter.evaluate(previousLine)
                
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
