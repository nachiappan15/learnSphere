//
//  Protocols.swift
//  LearnSphere
//
//  Created by Priyadharshan Raja on 11/10/24.
//
import ARKit
import UIKit

protocol RoomAssetsProtocol: AnyObject{
    func getReferenceImages() -> [ARReferenceImage]
    func get3DModels() -> [SCNNode]
    func getUserName() -> String
}
