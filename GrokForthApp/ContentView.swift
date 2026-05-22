import SwiftUI

struct ContentView: View {
    @State private var interpreter = GrokForthInterpreter()
    @State private var inputText = ""
    @State private var outputText = "=== GrokForth Ready ===\nType Forth commands below.\n\n"
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(outputText)
                    .font(.system(size: 14, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.white)
            .foregroundColor(.black)
            
            Divider()
            
            HStack {
                TextField("Forth> ", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 14, design: .monospaced))
                    .onSubmit { sendCommand() }
                
                Button("Send") {
                    sendCommand()
                }
            }
            .padding()
        }
        .frame(minWidth: 720, minHeight: 520)
    }
    
    private func sendCommand() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        outputText += "Forth> \(trimmed)\n"
        
        let result = interpreter.evaluate(trimmed)
        if !result.isEmpty {
            outputText += result + "\n"
        }
        
        inputText = ""
    }
}
