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
      
        aut.createUser(withEmail: email, password: password, completion: { (authResult, error) in
             
           uploadToDatabase(email: email, name: name,image:image,onSuccess: onSuccess)
          
            UserDefaults.standard.set(email, forKey: "email")
                        
           // print("user \(user) saved")
                  
            }
  )}
    
    //MARK: Upload user's infos to database
    static func uploadToDatabase(email: String, name: String,image:UIImage, onSuccess: @escaping () -> Void ){
        
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        
        let filename = NSUUID().uuidString
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
                

        
         ref.child("users").child(uid!).setValue(["email":email, "name":name , "profileImage": profileImageUrl ])
        onSuccess()
            }
        }
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
            UserDefaults.standard.set(email, forKey: "email")
            print("logged in user: \(user)"
        
   )}
}
    
//MARK:Fetching user's infos
static func getUserName(onSuccess: @escaping () -> Void , onError: @escaping (_ error: Error?) -> Void) {
    
    let ref = Database.database().reference()
    let defaults = UserDefaults.standard
    
    
    guard let uid = Auth.auth().currentUser?.uid else {
        //print("user not found")
        return
    }
    
    ref.child("users").child(uid).observe(.value, with: { snapshot in
    
        if let dictionary = snapshot.value as? [String:Any]{
            let username = dictionary["name"] as! String
            defaults.set(username, forKey: "userNameKey")
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
        let defaults = UserDefaults.standard
        let uid = Auth.auth().currentUser?.uid
        
        ref.child("users").child(uid!).observeSingleEvent(of:.value, with: { snapshot in
                    
            if !snapshot.exists(){return}
            
            //print(snapshot)
            
            if let dictionary = snapshot.value as? NSDictionary {
            
            //print(dictionary)
            /// if user doesn't upload a profile photo
                guard let profilePhoto = dictionary["profileImage"] as? String else{
                   return imageView.image = #imageLiteral(resourceName: "user_photo")
                }
                
            //print(profilePhoto)
                
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
                defaults.set(profilePhoto , forKey: "userPhotoKey")
            }
        })
    }
    
    
    //MARK: UPLOAD NEW POST TO DATABASE
    
    static func uploadPostsToDatabase(activityName: String, startingDate: String,endingDate: String,teamMembers:String ,onSuccess: @escaping () -> Void){
        
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let filename = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        
        
        storageRef.downloadURL { (downloadURL, err) in
                guard let postURL = downloadURL?.absoluteString else {return}
            
                print("uploading post succeed", postURL)
        }
    }
//
//        let postdic = [activityName:"activitiesName",startingDate:"startDate",endingDate:"endDate",teamMembers:"teamMembers" ]
//
//            ref.child("users").child(uid!).setValue(["email":email, "name":name , "profileImage": profileImageUrl ,"post":postURL])
//        onSuccess()
    
  
    
   
   //MARK: ALERTE FUNCTION
    static func createAlertController(title: String, message:String) -> UIAlertController {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(action)
            return alert
        }
    
    //MARK: CHECKING IF DATA EXISTS
   static func checkdataExsistance(firURL : String ,childNode : String,value : String,ChildKey : String, completion : @escaping(Bool)->()) {

        let ref = Database.database().reference()
        
        let newDB = ref.child(childNode).queryOrdered(byChild: ChildKey).queryEqual(toValue: value)
        
        newDB.observe(.value, with: { (snapshot) in
            print(snapshot.value ?? "No data")

        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //MARK: -Sending messages /conversations
    
    ///create new conversation function
    static func createNewConversation(with otherUserEmail: String ,name:String, firstMessage: Message , completion: @escaping (Bool)-> Void){
        
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        guard (UserDefaults.standard.value(forKey: "email") as? String) != nil else {
            return
        }
        ref.child("users").child(uid!).observeSingleEvent(of: .value, with: { snapshot in
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
                "otherUserEmail": otherUserEmail,
                "latest_message": [
                    "date" : dateString,
                    "message": message,
                    "is_read": false
                ]
            
            ]
            
            if var conversations = userNode["conversations"] as? [[String:Any]]{
                //conversation array exists for current user, should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.child("users").child(uid!).setValue(userNode, withCompletionBlock: { error,_ in
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
                ref.child("users").child(uid!).setValue(userNode, withCompletionBlock: {  error,_ in
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
    
    guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
        completion(false)
        return
    }
    
    let safeCurrentUserEmail = Service.safeEmail(email: currentUserEmail)
    
    let collectionMessage: [String:Any] = [
    
        "id": firstMessage.messageId,
        "type": firstMessage.kind.messageKindString ,
                "content": message,
                "date": dateString,
                "sender_email": safeCurrentUserEmail,
                "is_Read": false,
                "name": name
        
    ]
    
    let value : [String:Any] = [
        "messages":[
            collectionMessage
        ]
    
    ]
   
    ref.child("\(conversationID)").setValue(value,withCompletionBlock: { (error, _) in
        guard error == nil else {
            completion(false)
            return
        }
        completion(true)
    })
}
    
    ///Fetching and returning all conversations for the user with passed in email
    static func getAllConversations(for email:String, completion: @escaping (Result<[Conversation], Error>)-> Void){
        
        let ref = Database.database().reference()
        ref.child("\(email)/conversations").observe(.value, with: { (snapshot) in
            
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
        })

    }
    
    ///Gets all messages for a given conversation
    static func getAllMessagesForConversation(with id:String, completion: @escaping (Bool)-> Void){
        
    }
    
    ///Sends a message with target conversation and message
    static func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void){
        
    }
    
    
    
    //MARK: to avoid this bug *** Terminating app due to uncaught exception 'InvalidPathValidation', reason: '(child:) Must be a non-empty string and not contain '.' '#' '$' '[' or ']''
    
    static func safeEmail(email:String) -> String {
        
       
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
            
        }

    
    
    
    
    //MARK: DISMISS KEYBOARD
    static func dismissKeyboard(label:UITextField) {
        
    }
    
}
    
