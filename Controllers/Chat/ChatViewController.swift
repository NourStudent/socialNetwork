//
//  ChatViewController.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-16.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase



final class ChatViewController: MessagesViewController {
    
    private var snederPhotoURL: URL?
    private var otherUserPhotoURL: URL?
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var conversationId: String?
    public let otherUserEmail: String
    public var isNewConversation = false
    
    private var messages = [Message]()
    
    private var selfSender :Sender? {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as?String else {
            return nil
        }
       
      
        
        let safeCurrentEmail = Service.safeEmail(email: currentUserEmail ).lowercased()
       
   
        return Sender( photoURL: "",
                       senderId: safeCurrentEmail,
                       displayName: "Me")
        
       
    }
    
    init(with email: String, id: String?){
        
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
        if let conversationId = conversationId{
            listenForMessages(id: conversationId ,shouldScrollToBottom: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
   }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId{
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom:Bool){
        
        Service.getAllMessagesForConversation(with: id, completion: {[weak self] result in
            
          switch result {
            case .success(let messages):
                
                print("all Messages for one convo: successfully get conversation models\(messages)")
                print(id)
                
                guard !messages.isEmpty else{
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                    
                }
               
            case .failure(let error):
                print("failed to get messages \(error.localizedDescription)")
            }
        })
      
        
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: "", with: "").isEmpty , let selfSender = self.selfSender, let messageId = createMessageId() else {
            print("on bloque ici")
            return
            
        }
     
        print("sending:\(text)")
        //send Message
        let message = Message(
            sender: selfSender,
            messageId: messageId,
            sentDate: Date(),
            kind: .text(text))
        let safeOtherEmail = Service.safeEmail(email: otherUserEmail)
        
        if isNewConversation {
            //create new conversation in database
         
            Service.createNewConversation(with: safeOtherEmail, name: "\(self.title ?? "user")", firstMessage: message, completion: { success in
              
                if success {
                    print("message sent")
                    self.isNewConversation = false
                    let newConversationId = "conversation_ \(message.messageId)"
                    self.conversationId = newConversationId
                    self.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self.messageInputBar.inputTextView.text = nil
                    
                }else{
                    print("failed to send new message to new conversation")
                }
            })
            
           
        }
        else{
            //append to existing conversation in database
            guard let conversationId = conversationId ,let name = self.title else{
                return
            }
         
            Service.sendMessage(to: conversationId, otherUserEmail: safeOtherEmail, name: name, newMessage: message, completion: { success in
                
               
               if success {
                    print("message sent")
                self.messageInputBar.inputTextView.text = nil
                } else {
                    print("failed to send to existing conversation")
                }
            })
            
        }
}
    
    private func createMessageId() -> String? {
        //date , otherUserEmail, senderEmail , randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
       
      
        
        let safeCurrentEmail = Service.safeEmail(email: currentUserEmail ).lowercased()
        let safeOtherEmail = Service.safeEmail(email: otherUserEmail).lowercased()
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(safeOtherEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("created message id: \(newIdentifier)")
        
        return newIdentifier
    }
    
}

extension ChatViewController: MessagesDataSource , MessagesLayoutDelegate , MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        
        if let sender = selfSender{
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
      
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
        
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // our message
            return .link
        }
        //received message
        return .gray
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            //show our image
            if let currentUserImageUrl = self.snederPhotoURL{
                avatarView.sd_setImage(with: currentUserImageUrl, completed: nil)
            }else{
            //fetch url
                guard let user = Auth.auth().currentUser,let  email = user.email else {return}
               
                let safeEmail = Service.safeEmail(email: email)
                let path  = "profile_Images/\(safeEmail)_profile_picture.png"
                
                
                Service.downloadURL(for: path, completion: {result in
                    switch result {
                    case .success(let url):
                        self.snederPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }

        }else{
            //show other user image
            if let otherUserImageUrl = self.otherUserPhotoURL{
                avatarView.sd_setImage(with: otherUserImageUrl, completed: nil)
            }else{
            //fetch url
                let email = self.otherUserEmail
                let safeEmail = Service.safeEmail(email: email)
                let path  = "profile_Images/\(safeEmail)_profile_picture.png"
                
                
                Service.downloadURL(for: path, completion: {result in
                    switch result {
                    case .success(let url):
                        self.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        
                    case .failure(let error):
                        print("\(error)")
                    }
                })

            }
        }
    }
    
}
