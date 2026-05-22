import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var consoleText = "=== GrokForth Ready ===\n\n"
    @State private var currentInput = ""
    @FocusState private var inputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Console Output + Input Area
            ScrollView {
                ScrollViewReader { proxy in
                    Text(consoleText + currentInput)
                        .font(.system(size: 14, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)           // Allows selecting text
                        .onChange(of: consoleText) { _ in
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                }
            }
            .background(Color.white)
            .foregroundColor(.black)
            
            // Invisible input field (for keyboard input)
            TextField("", text: $currentInput)
                .focused($inputFocused)
                .opacity(0)
                .frame(height: 0)
                .onSubmit { submitInput() }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            inputFocused = true
        }
    }
    
    private func submitInput() {
        let command = currentInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else {
            currentInput = ""
            return
        }
        
        // Add command to console
        consoleText += "Forth> \(command)\n"
        
        // Execute Forth command
        let result = interpreter.evaluate(command)
        
        // Add result to console
        if !result.isEmpty {
            consoleText += result + "\n"
        }
        
        currentInput = ""
        
        // Keep focus on the invisible input field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            inputFocused = true
        }
    }
}
