import UIKit
import SceneKit

class ARModelPreviewViewController: UIViewController {
    
    private var currentUser: String
    private var sceneView: SCNView!
    var scene: SCNScene
    private var markerNodes: [SCNNode] = []
    private var markerNumbers: [Int:SCNVector3]  = [:]
    private var markedNodeDescriptions: [Int:String] = [:]
    private var addedNodes: [SCNNode] = []
    private var removedNodes: [SCNNode] = []
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
    
    init(scene: SCNScene,currentUser:String) {
        self.scene = scene
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .clear

        sceneView = SCNView(frame: self.view.bounds)
        sceneView.backgroundColor = UIColor.black
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        self.view.addSubview(sceneView)
        setupButtons()

        load3DModel()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    func load3DModel() {
        // Get the model node
        if let modelNode = scene.rootNode.childNodes.first {
            // Scale the model as necessary
            modelNode.scale = SCNVector3(0.5, 0.5, 0.5)
            
            // Calculate the bounding box
            let (minVec, maxVec) = modelNode.boundingBox
            let modelSize = SCNVector3(
                maxVec.x - minVec.x,
                maxVec.y - minVec.y,
                maxVec.z - minVec.z
            )
            
            // Calculate the center of the bounding box
            let center = SCNVector3(
                (minVec.x + maxVec.x) / 2,
                (minVec.y + maxVec.y) / 2,
                (minVec.z + maxVec.z) / 2
            )
            
            // Reposition the model so that its center aligns with (0, 0, 0)
            modelNode.position = SCNVector3(-center.x, -center.y, -center.z)
            
            // Calculate the maximum dimension of the model to determine camera distance
            let maxDimension = max(modelSize.x, modelSize.y, modelSize.z)
            let cameraDistance = maxDimension * 2.0  // Move camera far enough to see the whole model
            
            // Add a camera to view the model
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.name = "cameraNode"
            // Position the camera far enough to view the entire model
            cameraNode.position = SCNVector3(0, 0, cameraDistance)
            
            // Optionally, adjust camera's field of view to fit the model better
            cameraNode.camera?.fieldOfView = 60.0
            
            // Add the camera node to the scene
            scene.rootNode.addChildNode(cameraNode)
            
            // Add a light source to illuminate the model
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.position = SCNVector3(0, 10, 10)
            scene.rootNode.addChildNode(lightNode)
            
            // Set the scene to the view
            sceneView.scene = scene
        }
    }

    // Helper function to create a bounding box node for debugging
    func createBoundingBoxNode(min: SCNVector3, max: SCNVector3) -> SCNNode {
        let boxGeometry = SCNBox(
            width: CGFloat(max.x - min.x),
            height: CGFloat(max.y - min.y),
            length: CGFloat(max.z - min.z),
            chamferRadius: 0.0
        )
        boxGeometry.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.3)
        
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.position = SCNVector3(
            (min.x + max.x) / 2,
            (min.y + max.y) / 2,
            (min.z + max.z) / 2
        )
        return boxNode
    }

    // Helper function to center the model within the view's bounds
    func centerModelInView() {
        // Align the scene's center with the view's center
        if let cameraNode = scene.rootNode.childNode(withName: "cameraNode", recursively: true) {
            // Position the camera at the scene's center
            cameraNode.position = SCNVector3(0, 0, cameraNode.position.z)
            
            // Adjust camera field of view or orthographic scale (if using orthographic camera)
            cameraNode.camera?.fieldOfView = 20
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(location, options: nil)
        
        if let hit = hitResults.first {
            // Get the world coordinates of the hit location
            let hitPosition = hit.worldCoordinates
            // Check if the hit node is one of the markers (numbered text nodes)
            if let markerIndex = markerNodes.firstIndex(of: hit.node), markerIndex < markerNodes.count {
                showDescription(forNumber: markerIndex + 1)
                return
            }
            markPosition(at: hitPosition, withNumber: markerNumbers.count+1)
            getAnnotationText(at: hitPosition)
        }
    }
    
    private func getAnnotationText(at position: SCNVector3) {
        let alertController = UIAlertController(title: "Annotate", message: "Enter text and tap 'Annotate' to mark here or tap 'Cancel'", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Ex: This is cerebellum of brain...."
        }
        
        let submitAction = UIAlertAction(title: "Annotate", style: .default) { [weak self] _ in
            if let inputText = alertController.textFields?.first?.text {
                print("User input: \(inputText)")
                self?.handleAnnotationInput(inputText, position: position)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {[weak self] _ in
            self?.removeLastMarker()
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func handleAnnotationInput(_ input: String, position: SCNVector3) {
        print("User input processed: \(input)")
        addAnnotation(at: position, withText: input)
    }
    
    func addAnnotation(at position: SCNVector3, withText text: String) {
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.1, 0.1, 0.1)
        textNode.position = SCNVector3(position.x+2.0, position.y , position.z)
        
        addedNodes.append(textNode)
        
        scene.rootNode.addChildNode(textNode)
    }
    private func markPosition(at position: SCNVector3, withNumber number: Int) {
        // Create a 3D text geometry for the number
        let textGeometry = SCNText(string: "\(number)", extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red
        
        // Scale the text down for better visualization
        let textNode = SCNNode(geometry: textGeometry)
        textNode.scale = SCNVector3(0.05, 0.05, 0.05) // Scale the text appropriately

        // Adjust the text position to "embed" it in the model
        textNode.position = SCNVector3(position.x, position.y, position.z - 0.1) // Move it slightly inside the model

        // Ensure the text is facing outward from the model
        let cameraNode = scene.rootNode.childNode(withName: "cameraNode", recursively: true)

        if let cameraNode = cameraNode {
            // Calculate the direction from the text to the camera
            let direction = SCNVector3(
                cameraNode.position.x - textNode.position.x,
                cameraNode.position.y - textNode.position.y,
                cameraNode.position.z - textNode.position.z
            )
            
            // Adjust the orientation to face the camera
            textNode.look(at: SCNVector3(
                textNode.position.x + direction.x,
                textNode.position.y + direction.y,
                textNode.position.z + direction.z
            ))

            // Flip the text if necessary (to ensure it's readable)
            textNode.scale.z *= -1 // This may be necessary depending on how the text is rendered
        }

        // Add the marker (numbered text) to the scene
        markerNodes.append(textNode)
        scene.rootNode.addChildNode(textNode)

        // Store the marker and its associated number in a dictionary or array if needed
        markerNumbers[number] = position
        
        // Add the node to the addedNodes stack
        addedNodes.append(textNode)
    }
    
    private func setupButtons() {
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        let undoButton = UIButton(type: .system)
        undoButton.setTitle("Undo", for: .normal)
        undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        
        let redoButton = UIButton(type: .system)
        redoButton.setTitle("Redo", for: .normal)
        redoButton.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)

        buttonStack.addArrangedSubview(undoButton)
        buttonStack.addArrangedSubview(redoButton)

        self.view.addSubview(buttonStack)

        // Constraints for buttonStack
        NSLayoutConstraint.activate([
            buttonStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            buttonStack.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
        
        
        self.view.addSubview(chatButton)
        chatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        chatButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        chatButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        chatButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    
    @objc private func undoTapped() {
        guard let lastNode = addedNodes.popLast() else {
            return
        }
        
        lastNode.removeFromParentNode()
        removedNodes.append(lastNode)
    }
    
    @objc private func redoTapped() {
        guard let lastRemovedNode = removedNodes.popLast() else {
            return
        }
        
        scene.rootNode.addChildNode(lastRemovedNode)
        addedNodes.append(lastRemovedNode) 
    }
    
    private func showDescription(forNumber number: Int) {
        let description = markedNodeDescriptions[number] ?? "No description available."
        
        // Display an alert or custom description view
        let alertController = UIAlertController(title: "Marker \(number)", message: description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    // Function to remove the last marker
    private func removeLastMarker() {
        if let lastMarker = markerNodes.last {
            lastMarker.removeFromParentNode()
            markerNodes.removeLast()
        }
    }
    
    // Function to remove all markers
    private func removeAllMarkers() {
        for marker in markerNodes {
            marker.removeFromParentNode()
        }
        markerNodes.removeAll()
    }
    
    @objc private func chatButtonTapped() {
        let fireStoreHandler = FireStoreHandler()
        let initialVC = ChatViewController(roomId: "hwuSgKexEDCvRrgQkiPF", firestoreHandler: fireStoreHandler, currentUser: self.currentUser)
        navigationController?.pushViewController(initialVC, animated: true)
    }
}

extension SCNVector3 {
    static func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
}
