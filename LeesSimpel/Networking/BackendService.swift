import SwiftUI

final class BackendService: ObservableObject {
    func summarizeTranscript(transcript: String) async throws -> QueryResponse {
        //let url = URL(string: "http://localhost:5182/summarize_text")!
        let url = URL(string: "https://simpelbackend.azurewebsites.net/summarize_text")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject:["TextToSummarize": transcript] , options: [])
       
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw NSError(domain: "HTTP response error", code: (response as? HTTPURLResponse)?.statusCode ?? 0, userInfo: nil)
        }
        
        return try JSONDecoder().decode(QueryResponse.self, from: data)
    }
}
