//
//  Service.swift
//  socialNetwork
//
//  Created by Nour Achour on 2021-02-28.
//

import Foundation
import Firebase

class Service {
    
    
    //MARK: SIGN UP USER
    static func signUpUser(email:String,name:String, password:String,image:UIImage, onSuccess: @escaping () -> Void , onError: @escaping (_ error: Error?) -> Void) {
        let aut = Auth.auth()
        aut.createUser(withEmail: email, password: password){ (authResult, error )in
            guard let result = authResult , error == nil else{
                onError(error!)
                return
            }
            onSuccess()
            let user = result.user
            
            uploadToDatabase(email: email, name: name,image:image,onSuccess: onSuccess)
            
            UserDefaults.standard.setValue(email, forKey: "email")
            
            print("user Created: \(user)"
            )}
    }
    
    //MARK: Sign in user
    static func signIn (email:String , password:String, onSuccess: @escaping () -> Void , onError: @escaping (_ error: Error?) -> Void){
        
        let aut = Auth.auth()
        aut.signIn(withEmail: email, password: password) { (authResult, error )in
            guard let result = authResult , error == nil else{
                onError(error!)
                return
            }
            
            onSuccess()
            let user = result.user
            UserDefaults.standard.setValue(email, forKey: "email")
            print("logged in user: \(user)"
                  
            )}
    }
    
    
    //MARK: Upload user's infos to database
    static func uploadToDatabase(email: String, name: String,image:UIImage, onSuccess: @escaping () -> Void ){
        
        let ref = Database.database().reference()
        let safeEmail = Service.safeEmail(email: email).lowercased()
        
        
        let filename = "\(safeEmail)_profile_picture.png"
        let storageRef = Storage.storage().reference().child("profile_Images").child(filename)
        
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                print("uploading profile image failed" , err)
                return
            }
            storageRef.downloadURL { (downloadURL, err) in
                guard let profileImageUrl = downloadURL?.absoluteString else {return}
                
                print("uploading profile image succeed", profileImageUrl)
                
                let safeEmail = Service.safeEmail(email: email).lowercased()
                
                ref.child("users").child(safeEmail).setValue(["name":name ,"email":email, "profileImage": profileImageUrl ])
                
                UserDefaults.standard.setValue(name, forKey: "name")
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(profileImageUrl, forKey: "profileImage")
                onSuccess()
            }
        }
    }
    
    
    static func downloadURL(for path: String , completion:@escaping (Result<URL,Error>)-> Void){
        let reference = Storage.storage().reference().child(path)
        reference.downloadURL(completion: {url, error in
            guard let url = url, error == nil else{
                print("failed to download url")
                return
            }
            completion(.success(url))
        })
    }
    
    
    
    //MARK:Fetching user's infos
    static func getUserName(onSuccess: @escaping () -> Void , onError: @escaping (_ error: Error?) -> Void) {
        
        let ref = Database.database().reference()
        let defaults = UserDefaults.standard
        guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email else {
            return
        }
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        
        ref.child("users").child("\(safeEmail)").observe(.value, with: { snapshot in
            
            if let dictionary = snapshot.value as? [String:Any]{
                let username = dictionary["name"] as! String
                
                defaults.set(username, forKey: "name")
                onSuccess()
            }
            
        }) { error in
            //print("error failed to fetch user infos ")
            onError(error)
        }
    }
    
    //MARK: fetching users profiles images
    
    static func getUserProfilePhoto(imageView: UIImageView){
        
        
        let ref = Database.database().reference()
        
        guard let user = Auth.auth().currentUser else {return}
        guard let currentUserEmail = user.email else{return}
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        
        ref.child("users").child(safeEmail).observeSingleEvent(of:.value, with: { snapshot in
            
            if !snapshot.exists(){return}
            
            if let dictionary = snapshot.value as? NSDictionary {
                
                /// if user doesn't upload a profile photo
                guard let profilePhoto = dictionary["profileImage"] as? String else{
                    
                    return
                }
                
                
                let storageRef = Storage.storage().reference(forURL: profilePhoto)
                storageRef.downloadURL { (url, error) in
                    do{
                        let data = try Data(contentsOf: url!)
                        let image = UIImage(data: data as Data)
                        imageView.image = image
                        
                    } catch {
                        print(error.localizedDescription)
                        
                    }
                }
                
            }
        })
        
    }
    
    
    
    //MARK: ALERTE FUNCTION
    static func createAlertController(title: String, message:String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        return alert
    }
    
    
    
    
    //MARK: -Sending messages /conversations
    
    ///create new conversation function
    static func createNewConversation(with otherUserEmail: String ,name:String, firstMessage: Message , completion: @escaping (Bool)-> Void){
        
        
        let ref = Database.database().reference()
        
        guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email else {
            return
        }
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        guard let currentUserName = UserDefaults.standard.value(forKey: "name") else {
            return
        }
        
        ref.child("users").child(safeEmail).observeSingleEvent(of:.value, with: { snapshot in
            
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_ \(firstMessage.messageId)"
            
            let newConversationData : [String : Any] = [
                "id":conversationId,
                "name": name,
                "otherUserEmail": otherUserEmail.lowercased(),
                "latest_message": [
                    "date" : dateString,
                    "message": message,
                    "is_read": false
                ]
                
            ]
            
            
            let recipient_newConversationData : [String : Any] = [
                
                "id":conversationId,
                "name": currentUserName,
                "otherUserEmail": safeEmail,
                "latest_message": [
                    "date" : dateString,
                    "message": message,
                    "is_read": false
                ]
                
            ]
            
            //update recipient conversation entry
            ref.child("users").child("\(otherUserEmail.lowercased())/conversations").observeSingleEvent(of: .value, with: {snapshot in
                if var conversations = snapshot.value as? [[String: Any]]{
                    //append
                    conversations.append(recipient_newConversationData)
                    ref.child("\(otherUserEmail.lowercased())/conversations").setValue(conversations)
                    
                }else{
                    //create
                    ref.child("users").child("\(otherUserEmail.lowercased())/conversations").setValue([recipient_newConversationData])
                }
                
            })
            //update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                //conversation array exists for current user, should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.child("users").child("\(safeEmail)").setValue(userNode, withCompletionBlock: { error,_ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(
                        name:name,
                        conversationID: conversationId,
                        firstMessage: firstMessage,
                        completion: completion)
                })
            }else{
                //conversation array does not exist
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.child("users").child(safeEmail).setValue(userNode, withCompletionBlock: {  error,_ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    self.finishCreatingConversation(
                        name:name,
                        conversationID: conversationId,
                        firstMessage: firstMessage,
                        completion: completion)
                    
                    completion(true)
                })
            }
        })
        
    }
    
    static func finishCreatingConversation(name:String, conversationID:String, firstMessage: Message, completion: @escaping(Bool)->Void ) {
        
        let ref = Database.database().reference()
        
        
        var message = ""
        switch firstMessage.kind {
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        guard let user = Auth.auth().currentUser else {return}
        guard let currentUserEmail = user.email else{return}
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        let collectionMessage: [String:Any] = [
            
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString ,
            "content": message,
            "date": dateString,
            "sender_email": safeEmail,
            "is_Read": false,
            "name": name
            
        ]
        
        let value : [String:Any] = [
            "messages":[
                collectionMessage
            ]
            
        ]
        
        ref.child("allConversations").child("\(conversationID)").setValue(value,withCompletionBlock: { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    ///Fetching and returning all conversations for the user with passed in email
    static func getAllConversations(completion: @escaping (Result<[Conversation], Error>)-> Void){
        
        guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email  else {
            return
        }
        
        
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        let ref = Database.database().reference().child("users").child(safeEmail)
        ref.child("conversations").observe(.value, with: { (snapshot) in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                return
            }
            let conversations: [Conversation] = value.compactMap ({ dictionary  in
                
                guard let conversationId = dictionary["id"] as? String ,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["otherUserEmail"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else{
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        message: message,
                                                        isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
                
            })
            completion(.success(conversations))
            
        })
        
    }
    
    ///Gets all messages for a given conversation
    static func getAllMessagesForConversation(with id:String, completion: @escaping (Result<[Message],Error>) -> Void){
        
        //let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        ref.child("allConversations").child("\(id)").child("messages").observe(.value, with: { (snapshot) in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                return
            }
            let messages: [Message] = value.compactMap({dictionary in
                
                guard let content = dictionary["content"] as? String,
                      let date = dictionary["date"] as? String,
                      let messageID = dictionary["id"] as? String,
                      let isRead = dictionary["is_Read"] as? Bool,
                      let name = dictionary["name"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = ChatViewController.dateFormatter.date(from: date) else{
                    
                    return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: dateString,
                               kind:.text(content))
            })
            
            completion(.success(messages))
            
        })
        
    }
    
    ///Sends a message with target conversation and message
    static func sendMessage(to conversation: String,otherUserEmail:String ,name:String, newMessage: Message, completion: @escaping (Bool) -> Void){
        //add new message to messages
        //update sender latest message
        //update recipient message
        let ref = Database.database().reference()
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{return}
        let safeCurrentEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        
        ref.child("allConversations").child("\(conversation)/messages").observeSingleEvent(of: .value , with: { snapshot in
            guard var currentMessages = snapshot.value as? [[String:Any]] else{
                completion(false)
                return
            }
            
            
            var message = ""
            switch  newMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let messageDate =  newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            
            
            let newMessageEntry: [String:Any] = [
                
                "id":  newMessage.messageId,
                "type":  newMessage.kind.messageKindString ,
                "content": message,
                "date": dateString,
                "sender_email": safeCurrentEmail,
                "is_Read": false,
                "name": name
                
            ]
            currentMessages.append(newMessageEntry)
            ref.child("allConversations").child("\(conversation)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else{
                    completion(false)
                    return
                }
                
                ref.child("users").child("\(safeCurrentEmail)/conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                    print(snapshot)
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else{
                        completion(false)
                        return
                    }
                    
                    for var conversationDictionary in currentUserConversations {
                        
                        let updateValue:[String:Any] = [
                            "date": dateString,
                            "is_read": false,
                            "message": message
                        ]
                        
                        if let currentId = conversationDictionary["id"] as? String , currentId == conversation {
                            conversationDictionary["latest_message"] = updateValue
                            
                        }
                        currentUserConversations = [conversationDictionary]
                    }
                    
                    
                    
                    ref.child("users").child("\(safeCurrentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { (error, _) in
                        guard error == nil else{
                            completion(false)
                            return
                        }
                        
                        //Update latest message for recipient user
                        
                        ref.child("users").child("\(otherUserEmail.lowercased())/conversations").observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else{
                                completion(false)
                                return
                            }
                            
                            for var conversationDictionary in otherUserConversations {
                                
                                let updateValue:[String:Any] = [
                                    "date": dateString,
                                    "is_read": false,
                                    "message": message
                                ]
                                
                                if let currentId = conversationDictionary["id"] as? String , currentId == conversation {
                                    conversationDictionary["latest_message"] = updateValue
                                    
                                }
                                otherUserConversations = [conversationDictionary]
                            }
                            
                            
                            
                            ref.child("users").child("\(otherUserEmail.lowercased())/conversations").setValue(otherUserConversations, withCompletionBlock: { (error, _) in
                                guard error == nil else{
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
    
    
    
    //MARK: to avoid this bug *** Terminating app due to uncaught exception 'InvalidPathValidation', reason: '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
    
    static func safeEmail(email:String) -> String {
        
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
        
    }
    
    
    //MARK: Handling posts
    ///create new post
    
    static func createNewPost (postId:String,activityName: String, startingDate: String,endingDate: String,teamMembers:String,location:String ,completion: @escaping (Bool) -> Void){
        
        let ref = Database.database().reference()
        
        guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email else {
            return
        }
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        guard let currentUserName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        
        guard let currentUserPhoto = UserDefaults.standard.value(forKey: "profileImage") as? String else {
            return
        }
        
        
        let timestamp = Date().timeIntervalSince1970
        // gives date with time portion in UTC 0
        let date = Date(timeIntervalSince1970: timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy"  // change to your required format
        dateFormatter.timeZone = TimeZone.current
        
        // date with time portion in your specified timezone
        let dateString = dateFormatter.string(from: date)
        print("dateString: \(dateString)")
        
        
        ref.child("users").child(safeEmail).observeSingleEvent(of:.value, with: { snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let newPostData: [String:Any] = [
                "id": postId,
                "activityName":activityName,
                "date":dateString
            ]
            
            userNode["Lastpost"] = [
                newPostData
            ]
            
            ref.child("users").child(safeEmail).setValue(userNode, withCompletionBlock: {  error,_ in
                guard error == nil else{
                    completion(false)
                    return
                }
                self.finishCreatingPost(authorImage: currentUserPhoto,author: currentUserName ,postID:postId,activityName:activityName,startingDate:startingDate,endingDate:endingDate,teamMembers:teamMembers,location:location,
                                        completion:completion)
                completion(true)
                
            })
            
        })
    }
    
    
    static func finishCreatingPost(authorImage:String,author:String,postID:String,activityName:String,startingDate:String,endingDate:String,teamMembers:String,location:String,
                                   completion:@escaping (Bool)->Void){
        let ref = Database.database().reference()
        
        let timestamp = Date().timeIntervalSince1970
        // gives date with time portion in UTC 0
        let date = Date(timeIntervalSince1970: timestamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM-dd-yyyy"  // change to your required format
        dateFormatter.timeZone = TimeZone.current
        
        // date with time portion in your specified timezone
        let dateString = dateFormatter.string(from: date)
        print("dateString: \(dateString)")
        
        let postID = "activity_\(postID)"
        let collectionPost: [String:Any] = [
            "id": postID,
            "author":author,
            "authorImage": authorImage,
            "date": dateString,
            "activityName": activityName,
            "startingDate": startingDate,
            "endingDate": endingDate,
            "teamMembers":teamMembers,
            "Location": location
            
        ]
        
        let value : [String:Any] = collectionPost
        
        ref.child("allPosts").child("\(postID)").setValue(value,withCompletionBlock: { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
        
    }
    
    
    
    static func favoriteActivities(activityName:String,completion: @escaping (Bool) -> Void) {
        
        let ref = Database.database().reference()
        
        guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email else {
            return
        }
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        
        
        ref.child("users").child(safeEmail).observeSingleEvent(of:.value, with: { snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            if var posts = userNode["favoriteActivities"] as? [String] {
                posts.append(activityName)
                userNode["favoriteActivities"] = posts
                
                
                //favoriteActivities array already exist
                ref.child("users").child(safeEmail).setValue(userNode, withCompletionBlock: {  error,_ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                    
                    
                })
            }else{
                //favoriteActivities array does not exist
                userNode["favoriteActivities"] = [activityName]
                ref.child("users").child(safeEmail).setValue(userNode,withCompletionBlock: {
                    error,_ in
                    guard error == nil else{
                        completion(false)
                        return
                    }
                })
            }
        }
        )}
    
    
    
    static func deleteFromFavoriteActivity(activityName:String ,completion: @escaping ((Bool) -> Void)){
        
        let ref = Database.database().reference()
        
        guard let user = Auth.auth().currentUser ,let currentUserEmail = user.email else {
            return
        }
        let safeEmail = Service.safeEmail(email: currentUserEmail).lowercased()
        let reference =  ref.child("users").child("\(safeEmail)").child("favoriteActivities")
        
        reference.observeSingleEvent(of: .value, with: {snapshot in
            if var favoriteActivities = snapshot.value as? [String] {
                var postionToRemove = 0
                for activity in favoriteActivities {
                    if activity == activityName {
                        break
                    }
                    postionToRemove += 1
                }
                favoriteActivities.remove(at: postionToRemove)
                reference.setValue(favoriteActivities, withCompletionBlock: {error,_ in
                    guard error == nil else{
                        completion(false)
                        print("Failed to delete activity from favoriteActivities array")
                        return
                    }
                    completion(true)
                    print("deleted activity from favoriteActivities array succefully")
                })
            }
            
        })
    }
}





public enum DatabaseError: Error {
    case failedToFetch
    
    public var localizedDescription: String {
        switch self {
        case .failedToFetch:
            return "Database fetching failed"
        }
    }
}




