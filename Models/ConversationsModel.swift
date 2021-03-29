//
//  ConversationsModel.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-03-25.
//

import Foundation


struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let message: String
    let isRead: Bool
}
