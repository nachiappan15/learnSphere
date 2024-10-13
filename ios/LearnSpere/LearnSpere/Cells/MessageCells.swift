//
//  MessageCells.swift
//  LearnSphere
//
//  Created by Priyadharshan Raja on 11/10/24.
//

import UIKit

class MyMessageCell: UITableViewCell {
    let messageLabel = UILabel()
    let messageContainer = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

    }

    private func setupUI() {
        messageContainer.backgroundColor = UIColor.systemYellow
        messageContainer.layer.cornerRadius = 16
        messageContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageContainer)
        
        // Message Label
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageContainer.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250),

            messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -12),
            messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -8),
        ])
    }
}

class OtherMessageCell: UITableViewCell {
    let messageLabel = UILabel()
    let messageContainer = UIView()
    let senderLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        contentView.backgroundColor = .clear
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        // Sender's name label
        senderLabel.font = UIFont.boldSystemFont(ofSize: 12)
        senderLabel.textColor = .darkGray
        senderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(senderLabel)
        
        // Message Container (Bubble)
        messageContainer.backgroundColor = UIColor(white: 0.9, alpha: 1)
        messageContainer.layer.cornerRadius = 16
        messageContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageContainer)
        
        // Message Label
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageContainer.addSubview(messageLabel)
        
        // Constraints for senderLabel, messageContainer, and messageLabel
        NSLayoutConstraint.activate([
            senderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            senderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            
            messageContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageContainer.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 2),
            messageContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            messageContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            messageLabel.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor, constant: -12),
            messageLabel.topAnchor.constraint(equalTo: messageContainer.topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainer.bottomAnchor, constant: -8),
        ])
    }
}
