import Foundation
import ARKit

class ARTrackingViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var datasource: RoomAssetsProtocol
    var imagesToTrack: Set<ARReferenceImage>?
    var downloaded3DModels: [SCNNode]?
    
    private lazy var arSceneView: ARSCNView = {
        let arSceneView = ARSCNView()
        arSceneView.translatesAutoresizingMaskIntoConstraints = false
        arSceneView.delegate = self
        arSceneView.debugOptions = [.showFeaturePoints]
        arSceneView.autoenablesDefaultLighting = true
        arSceneView.automaticallyUpdatesLighting = true
        if let camera = arSceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
        }
        arSceneView.isUserInteractionEnabled = false
        return arSceneView
    }()
    
    private lazy var focusImageView: UIImageView = {
        let focusImageView = UIImageView()
        focusImageView.contentMode = .scaleAspectFit
        focusImageView.translatesAutoresizingMaskIntoConstraints = false
        focusImageView.image = UIImage(named: "AR_focus")
        focusImageView.tintColor = .white
        focusImageView.alpha = 0.4
        return focusImageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.textColor = .white
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        return messageLabel
    }()
    
    init(datasource: RoomAssetsProtocol) {
        self.datasource = datasource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.configureView()
        self.imagesToTrack = Set(datasource.getReferenceImages())
        self.downloaded3DModels = datasource.get3DModels()
    }
    
    private func configureView() {
        arSceneView.session.delegate = self
        arSceneView.delegate = self
        
        self.view.addSubview(arSceneView)
        arSceneView.addSubview(focusImageView)
        arSceneView.addSubview(messageLabel)
        
        let focusGuide = UILayoutGuide()
        arSceneView.addLayoutGuide(focusGuide)
        
        NSLayoutConstraint.activate([
            arSceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            arSceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            arSceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            arSceneView.topAnchor.constraint(equalTo: self.view.topAnchor),
            
            focusGuide.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            focusGuide.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            focusGuide.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            focusGuide.topAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            focusImageView.topAnchor.constraint(equalTo: focusGuide.topAnchor),
            focusImageView.leadingAnchor.constraint(equalTo: focusGuide.leadingAnchor, constant: 50),
            focusImageView.trailingAnchor.constraint(equalTo: focusGuide.trailingAnchor, constant: -50),
            focusImageView.widthAnchor.constraint(equalTo: focusImageView.heightAnchor),
            
            messageLabel.leadingAnchor.constraint(equalTo: focusGuide.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: focusGuide.trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: focusGuide.bottomAnchor),
            messageLabel.topAnchor.constraint(equalTo: focusImageView.bottomAnchor, constant: 25),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureImageTrackingSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.arSceneView.session.pause()
    }
    
    private func configureImageTrackingSession() {
        let config = ARWorldTrackingConfiguration()
        
        guard let imagesToTrack = self.imagesToTrack else {return}
        guard !imagesToTrack.isEmpty else {
            print("No reference images to track")
            return
        }
        config.detectionImages = self.imagesToTrack
        self.arSceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    private func createScene(with node: SCNNode) -> SCNScene {
        let scene = SCNScene()
        scene.rootNode.addChildNode(node)
        return scene
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor {
            if let markerName = (imageAnchor.name as NSString?)?.deletingPathExtension {
                guard let downloaded3DModels = self.downloaded3DModels else {return}
                for model in downloaded3DModels {
                    if model.name == markerName {
                        let scene = createScene(with: model)
                        
                        DispatchQueue.main.async {
                            var currentUser = self.datasource.getUserName()
                            let ARModelPreviewVC = ARModelPreviewViewController(scene: scene, currentUser: currentUser)
                            self.navigationController?.pushViewController(ARModelPreviewVC, animated: true)
                        }
                        break
                    }
                }
            } else {
                print("Image anchor has no name or couldn't delete path extension")
            }
        }
    }
}
