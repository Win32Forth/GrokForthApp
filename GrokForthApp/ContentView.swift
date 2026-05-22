import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var consoleText = "=== GrokForth Ready ===\n\n"
    @State private var currentInput = ""
    @FocusState private var inputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Main scrolling console area
            ScrollView {
                ScrollViewReader { proxy in
                    Text(consoleText + currentInput)
                        .font(.system(size: 14, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .textSelection(.enabled)
                        .id("bottom")
                        .onChange(of: consoleText) { _ in
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                }
            }
            .background(Color.white)
            .foregroundColor(.black)
            .scrollDisabled(false)           // Important for mouse wheel
            
            // Invisible input handler
            .overlay {
                TextField("", text: $currentInput)
                    .focused($inputFocused)
                    .opacity(0)
                    .frame(width: 0, height: 0)
                    .onSubmit { submitInput() }
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onTapGesture {
            inputFocused = true
        }
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
        
        consoleText += "Forth> \(command)\n"
        
        let result = interpreter.evaluate(command)
        if !result.isEmpty {
            consoleText += result + "\n\n"
        } else {
            consoleText += "\n"
        }
        
        currentInput = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            inputFocused = true
        }
    }
}
