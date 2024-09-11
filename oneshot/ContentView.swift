import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State var answer: String = "..."
    var body: some View {
        let msg = Message(role: "user", content: "hello?")
        let c = Completion(messages: [msg], model: model.llama3.rawValue, choices: nil, error: nil)
        let key = "secret1234"
        Text(answer)
            .task {
                do {
                    let completed = try await complete(apiRoot: groq, key: key, prompt: c)
                    answer = completed.choices![0].message.content
                } catch completionError.unauthorized {
                    print("unauthorized")
                } catch {
                    print(error)
                }
            }
    }
}

/*
#Preview {
    ContentView()
}
*/
