//
//  OpenAI.swift
//  IkEetKip
//
//  Created by Jordi Bruin on 10/02/2023.
//

import Foundation

//This code provides a function to send a request to the OpenAI API to generate text completions based on a given prompt. It also provides functions to decode the response from the OpenAI API into a Swift object, and a struct to represent the response. It also includes some default values to be used in the request.
public class OpenAI {

    static let shared: OpenAI = OpenAI()
    private init() {}
    
    let openAIURL = URL(string: "https://api.openai.com/v1/completions")
            
    func processPromptAsync(prompt: String) async throws -> String {
        let httpBody: [String: Any] = [
            "model" : "text-davinci-003",
            "prompt" : prompt,
            "max_tokens" : 1024,
            "temperature": 0
        ]
        
        let data: Data = try JSONSerialization.data(withJSONObject: httpBody)
        
//        guard !apiKey.isEmpty else { return "No API Key"}
        var request = URLRequest(url: self.openAIURL!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \("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")", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody = data
        
        do {
            let (response, _) = try await URLSession.shared.data(for: request)
            
            do {
                let result = try JSONDecoder().decode(OpenAIResponse.self, from: response)
                print(result.choices)
                
                if var firstResult = result.choices.first?.text {
                    if firstResult.prefix(2) == "\n\n" {
                        firstResult.removeFirst(2)
                        return firstResult
                    } else {
                        return firstResult
                    }
                } else {
                    return ""
                }
            } catch {
                let error = try JSONDecoder().decode(OpenAIErrorResponse.self, from: response)
                print(error.error.message)
                
                return "Could not generate output because there is something wrong with your OpenAI account: \n\(error.error.message)"
            }
        } catch {
            
            print(error.localizedDescription)
            return "Could not generate output because there is something wrong with your OpenAI account. \(error.localizedDescription)"
        }
    }
    
}


struct OpenAIErrorResponse: Codable {
    let error: OpenAIErrorMessage
}

struct OpenAIErrorMessage: Codable {
    let message: String
    let type: String
}

struct OpenAIResponse: Codable {
    var id: String
    var object: String
    var created: Int
    var model: String
    var choices: [Choice]
}

//
//  OpenAIResponseHandler.swift
//  Story Time
//
//  Created by Jordi Bruin on 07/12/2022.
//

import Foundation

struct OpenAIResponseHandler {
    func decodeJson(jsonString: String) -> OpenAIResponse? {
        let json = jsonString.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        do {
            let product = try decoder.decode(OpenAIResponse.self, from: json)
            return product
            
        } catch {
            print("Error decoding OpenAI API Response")
        }
        
        return nil
    }
    
    
}

//
//  Choice.swift
//  Story Time
//
//  Created by Jordi Bruin on 07/12/2022.
//

import Foundation

struct Choice: Codable {
    var text: String
    var index: Int
    var logprobs: String?
    var finish_reason: String
    
    static let example = Choice(text: "Once upon a time there was a beautiful princess named Rose. She lived in a faraway kingdom, surrounded by lush green forests, crystal clear rivers, and rolling hills.\n\nOne day, Rose decided to go for a walk in the forest. She grabbed her bright pink umbrella and set off. The sun was shining and the birds were chirping as she made her way through the trees", index: 0, finish_reason: "")
}

