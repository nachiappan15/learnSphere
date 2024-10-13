//
//  RoomViewController.swift
//  LearnSphere
//
//  Created by Priyadharshan Raja on 11/10/24.
//

import UIKit

class RoomViewController: UIViewController {
    private var roomID: String
    var roomName: String = ""
    var participantsCount: Int = 0
    var datasource: RoomAssetsProtocol?
    
    init(roomID: String, datasource: RoomAssetsProtocol? = nil) {
        self.roomID = roomID
        self.datasource = datasource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let roomTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let participantsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let chatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message.fill"), for: .normal)  // System chat icon
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(chatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to the room! Learn, Collaborate and chat with participants."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .clear
        setBackgroundImage()
        setupUI()
        configureRoomDetails()
    }
    
    private func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "HomeWallpaper")
        backgroundImageView.contentMode = .scaleToFill

        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    private func setupUI() {
        navigationItem.title = "Room"
        
        let scanButton = UIBarButtonItem(image: UIImage(systemName: "qrcode.viewfinder"), style: .plain, target: self, action: #selector(scanButtonTapped))
        navigationItem.rightBarButtonItem = scanButton
        
        // Add room title label
        view.addSubview(roomTitleLabel)
        roomTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        roomTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        roomTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        // Add participants label
        view.addSubview(participantsLabel)
        participantsLabel.topAnchor.constraint(equalTo: roomTitleLabel.bottomAnchor, constant: 10).isActive = true
        participantsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        participantsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        // Add info label
        view.addSubview(infoLabel)
        infoLabel.topAnchor.constraint(equalTo: participantsLabel.bottomAnchor, constant: 20).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        // Add chat button
        view.addSubview(chatButton)
        chatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        chatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        chatButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        chatButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func configureRoomDetails() {
        // Set room title and participants details
        roomTitleLabel.text = roomName
        participantsLabel.text = "\(participantsCount) participants"
    }
    
    // Action for the chat button
    @objc private func chatButtonTapped() {
        let fireStoreHandler = FireStoreHandler()
        let currentUser = datasource?.getUserName()
        print("Current User is \(currentUser)")
        let initialVC = ChatViewController(roomId: roomID, firestoreHandler: fireStoreHandler, currentUser: currentUser!)
        navigationController?.pushViewController(initialVC, animated: true)
    }
    
    @objc private func scanButtonTapped() {
        guard let datasource = self.datasource else {return}
        let ARtrackingVC = ARTrackingViewController(datasource: datasource)
        self.navigationController?.pushViewController(ARtrackingVC, animated: true)
    }
}
