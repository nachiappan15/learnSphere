//
//  Firebase.swift
//  LearnSphere
//
//  Created by Priyadharshan Raja on 11/10/24.
//
import FirebaseCore
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class FireStoreHandler {
    
    let db = Firestore.firestore()
    
    // 1. Create a chat room
    func createRoom(roomName: String, completion: @escaping (String?) -> Void) {
        let roomId = UUID().uuidString
        
        db.collection("rooms").document(roomId).setData([
            "roomName": roomName,
            "createdAt": FieldValue.serverTimestamp(),
            "createdBy": Auth.auth().currentUser?.uid ?? "anonymous"
        ]) { error in
            if let error = error {
                print("Error creating room: \(error.localizedDescription)")
                completion(nil)
            } else {
                print("Room created successfully!")
                completion(roomId)
            }
        }
    }
    
    // 2. Send a message to a chat room
    func sendMessage(roomId: String, messageText: String, userId: String?, completion: @escaping (Bool) -> Void) {
        let messageId = UUID().uuidString
        
        db.collection("rooms").document(roomId).collection("messages").document(messageId).setData([
            "userId": userId ?? "anonymous",
            "text": messageText,
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Message sent successfully!")
                completion(true)
            }
        }
    }
    
    // 3. Listen for new messages in a chat room
    func listenForMessages(roomId: String, completion: @escaping ([Message]) -> Void) {
        db.collection("rooms").document(roomId).collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching messages: \(error.localizedDescription)")
                    return
                }
                
                guard let snapshot = querySnapshot else { return }
                
                var messages: [Message] = []
                
                for document in snapshot.documents {
                    let data = document.data()
                    let userId = data["userId"] as? String ?? "unknown"
                    let text = data["text"] as? String ?? ""
                    let timestamp = data["timestamp"] as? Timestamp ?? Timestamp()
                    
                    let message = Message(userId: userId, text: text, timestamp: timestamp.dateValue())
                    messages.append(message)
                }
                completion(messages)
            }
    }
    
    // 4. Fetch all available rooms
    func fetchRooms(completion: @escaping ([Room]) -> Void) {
        db.collection("rooms").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching rooms: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            var rooms: [Room] = []
            
            for document in snapshot.documents {
                let data = document.data()
                let roomName = data["roomName"] as? String ?? "Unnamed Room"
                let roomId = document.documentID
                
                let room = Room(roomId: roomId, roomName: roomName)
                rooms.append(room)
            }
            
            completion(rooms)  // Pass back the array of rooms
        }
    }
    
    // 5. Delete a room
    func deleteRoom(roomId: String, completion: @escaping (Bool) -> Void) {
        db.collection("rooms").document(roomId).delete { error in
            if let error = error {
                print("Error deleting room: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Room deleted successfully!")
                completion(true)
            }
        }
    }
}


struct Message {
    let userId: String
    let text: String
    let timestamp: Date
}

// Room struct to hold room data
struct Room {
    let roomId: String
    let roomName: String
}
