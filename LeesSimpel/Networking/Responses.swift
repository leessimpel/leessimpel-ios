//
//  Responses.swift
//  IkEetKip
//
//  Created by Niels Hoogendoorn on 20/02/2023.
//

import Foundation

struct SentenceItem: Codable, Identifiable {
    var id: String { text }
    let text: String
    let emoji: String
}

struct QueryResponse: Codable {
    let sender: String
    let call_to_action: String
    let call_to_action_is_call: Bool
    let phone_number: String?
    let summary_sentences: [SentenceItem]
}

struct DecodeError: LocalizedError {

    var errorDescription: String? { internalError.localizedDescription }
    let internalError: Error
    let result: String
}
