//
//  ChatViewController.swift
//  LearnSphere
//
//  Created by Priyadharshan Raja on 11/10/24.
//

import Foundation
import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var roomId : String
    let firestore: FireStoreHandler
    private var currentUser :String = "Anonymous"
    
    let blurEffectView = UIVisualEffectView()
    private let tableView = UITableView()
    private let messageInputBar = UIView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)

    private var chatMessages: [String] = ["Welcome to the Group Chat!"]
    private var messages: [Message] = []
    
    init(roomId: String, firestoreHandler: FireStoreHandler, currentUser: String) {
        self.roomId = "hwuSgKexEDCvRrgQkiPF"
        self.currentUser = currentUser
        self.firestore = firestoreHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .clear
        checkRooomAvaiability()
        setupUI()
        configureTableView()
        listenForMessages()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollToBottom(animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.backgroundColor = .clear
    }
    
    private func checkRooomAvaiability(){
        firestore.fetchRooms{ rooms in
            var flag = false
            for room in rooms{
                if room.roomId == self.roomId{
                    flag = true
                }
            }
            if !flag{
                self.firestore.createRoom(roomName: self.roomId, completion: { room in
                    print("Room Id created on name \(room ?? "Nothing")")
                })
            }
        }
    }
    
    private func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MyMessageCell.self, forCellReuseIdentifier: "MyMessageCell")
        tableView.register(OtherMessageCell.self, forCellReuseIdentifier: "OtherMessageCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tableView.addGestureRecognizer(tapGesture)
        
        messageTextField.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            tableView.bottomAnchor.constraint(equalTo: messageTextField.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        scrollToBottom(animated: true)
    }

    private func listenForMessages(){
        firestore.listenForMessages(roomId: roomId, completion: {
            messages in
            if !messages.isEmpty{
                for message in messages {
                    self.messages.append(message)
                }
                self.messages = messages
                self.tableView.reloadData()
            }
            else{
                print("Oops not listening")
            }
        })
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setBackgroundImage()
        setupBlurEffect()
        self.navigationController?.navigationItem.title = "Room Chat"
        messageInputBar.backgroundColor = UIColor.systemGray5
        messageInputBar.layer.borderWidth = 1.0
        messageInputBar.layer.borderColor = UIColor.systemGray4.cgColor
        view.addSubview(messageInputBar)
        
        messageTextField.placeholder = "Enter message..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.returnKeyType = .send
        messageInputBar.addSubview(messageTextField)
        
        sendButton.setImage(UIImage(systemName: "greaterthan"), for: .normal)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        messageInputBar.addSubview(sendButton)
        
        view.addSubview(tableView)
        setupConstraints()
    }
    
    func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "Chat_Screen_Wallpaper")
        backgroundImageView.contentMode = .scaleToFill

        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }

    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            messageTextField.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 10),
            messageTextField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor)
        ])
    }

    // MARK: - UITableView DataSource and Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count-1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message.userId == currentUser {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MyMessageCell else {
                return UITableViewCell()
            }
            cell.messageLabel.text = message.text
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OtherMessageCell", for: indexPath) as? OtherMessageCell else {
                return UITableViewCell()
            }
            cell.messageLabel.text = message.text
            cell.senderLabel.text = message.userId
            return cell
        }
    }

    // MARK: - Button and TextField Handlers
    @objc private func sendButtonTapped() {
        if let messageText = messageTextField.text, !messageText.isEmpty {
            sendMessage(messageText)
            firestore.fetchRooms { rooms in
                for room in rooms {
                    print("Room ID: \(room.roomId), Room Name: \(room.roomName)")
                }
            }
            firestore.sendMessage(roomId: roomId, messageText: messageText, userId: currentUser){ success in
                if success{
                    print("Message Sent!")
                }
                else{
                    print("Message Not Sent!")
                }
            }
            messageTextField.text = ""
        }
    }

    private func sendMessage(_ message: String) {
        chatMessages.append(message)
        tableView.reloadData()

        let indexPath = IndexPath(row: messages.count - 2, section: 0)
        if indexPath.row > 0{
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }

    @objc private func dismissKeyboard() {
        messageTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let messageText = textField.text, !messageText.isEmpty {
            sendMessage(messageText)
            textField.text = ""
        }
        return true
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            
            UIView.animate(withDuration: 0.3) {
                self.messageInputBar.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight+32)
                self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + self.messageInputBar.frame.height, right: 0)
                self.tableView.scrollIndicatorInsets = self.tableView.contentInset
            }
            scrollToBottom(animated: true)
        }
    }
    private func scrollToBottom(animated: Bool) {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 2, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
        }
    }
    @objc private func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.messageInputBar.transform = .identity
            self.tableView.contentInset = .zero
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let maxBlurAlpha: CGFloat = 1.0
        let minBlurAlpha: CGFloat = 0.0
        let blurAlpha = max(minBlurAlpha, min(maxBlurAlpha, offset / 200)) // Adjust 200 as needed
        
        blurEffectView.alpha = blurAlpha
    }
    private func setupBlurEffect() {
        let blurEffect = UIBlurEffect(style: .regular)
        
        blurEffectView.effect = blurEffect
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        
        NSLayoutConstraint.activate([
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.heightAnchor.constraint(equalToConstant: 100) // Adjust height as needed
        ])
        
       view.bringSubviewToFront(blurEffectView)
    }
}
