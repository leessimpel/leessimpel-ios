//
//  PromptService.swift
//  IkEetKip
//
//  Created by Niels Hoogendoorn on 20/02/2023.
//

import SwiftUI

final class PromptService: ObservableObject {

    func sendItems(items: [String]) async throws -> QueryResponse {
        let completeString = items.joined(separator: "\n")
        return try await sendPrompt(transcript: completeString)
    }

    func sendPrompt(transcript: String) async throws -> QueryResponse {

        let prompt = """
\(transcript)
=================================
Summarize this essence of this letter into different sentences.
Each sentence should be:
- dutch, at A2/1F level
- informal
- address the reader
- friendly

return JSON format with keys for:
“sender”,  short name of the sender
“call_to_action”,
“call_to_action_is_call”: indicates if the call to action is to make a phonecall
"phone_number”,  the phonenumber should not have any additional punctuation or characters
“summary_sentences” with as subfields "emoji” and "text”.

Make sure you return a valid JSON syntax.
"""

        print("===========BEGINTRANSCRIPT")
        print(transcript)
        print("===========ENDTRANSCRIPT")

//        Task { @MainActor in
        let simplifyResult = try await OpenAI.shared.processPromptAsync(prompt: prompt)
            let jsonObjectData = Data(simplifyResult.utf8)
        do {
            return try JSONDecoder().decode(
                QueryResponse.self,
                from: jsonObjectData
            )
        } catch {
            throw DecodeError(internalError: error, result: simplifyResult)
        }
    }
}
