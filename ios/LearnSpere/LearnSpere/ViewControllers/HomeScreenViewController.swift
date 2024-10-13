//
//  ViewController.swift
//  AR-Edu-App
//
//  Created by Priyadharshan Raja on 25/09/24.
//

import UIKit
import ARKit

class HomeScreenViewController: UIViewController {
    
    private var userName = "Anonymous"
    private var activityIndicator: UIActivityIndicatorView?
    private var loadingView: UIView?
    private var loadingMessages: [String] = ["Verifying Room ID", "Downloading Room Assets", "Entering Room"]
    private var currentMessageIndex = 0
    private var loadingMessageLabel: UILabel?
    
    let appTitleLabel = UILabel()
    let tenantRoomIdTextField = UITextField()
    let tenantNameTextField = UITextField()
    let submitButton = UIButton(type: .system)
    var appTitleContainerView = UIView()
    var appSubTitle = UILabel()
    
    private var referenceImages : [ARReferenceImage] = []
    private var downloded3DModels : [SCNNode] = []
    
    private var downloadModelsAPI = "https://mole-natural-ghoul.ngrok-free.app/files/"
    private var getFilesAPI = "https://mole-natural-ghoul.ngrok-free.app/ios/"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        addObservers()

        appTitleLabel.text = "LearnSphere"
        appTitleLabel.font = UIFont.boldSystemFont(ofSize: 50)
        appTitleLabel.backgroundColor = .black
        appTitleLabel.textAlignment = .left
        appTitleLabel.layer.cornerRadius = 10
        appTitleLabel.layer.masksToBounds = true
        appTitleLabel.textColor = UIColor.label
        appTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        appTitleContainerView.addSubview(appTitleLabel)

        appSubTitle.text = "The quick brown fox jumps over the lazy dog"
        appSubTitle.numberOfLines = 3
        appSubTitle.font = UIFont.boldSystemFont(ofSize: 20)
        appSubTitle.backgroundColor = .clear
        appSubTitle.translatesAutoresizingMaskIntoConstraints = false
        appTitleContainerView.addSubview(appSubTitle)
        
        appTitleContainerView.backgroundColor = .clear
        view.addSubview(appTitleContainerView)
        appTitleContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appTitleContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appTitleContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -70),
            appTitleContainerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,constant: 20),
            appTitleContainerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            appTitleContainerView.heightAnchor.constraint(equalToConstant: 180)
        ])
        
        appTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            appTitleLabel.topAnchor.constraint(equalTo: appTitleContainerView.topAnchor),
            appTitleLabel.leadingAnchor.constraint(equalTo: appTitleContainerView.leadingAnchor),
            appTitleLabel.trailingAnchor.constraint(equalTo: appTitleContainerView.trailingAnchor, constant: -30),
            appTitleLabel.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        NSLayoutConstraint.activate([
            appSubTitle.topAnchor.constraint(equalTo: appTitleLabel.bottomAnchor, constant: -15),
            appSubTitle.leadingAnchor.constraint(equalTo: appTitleContainerView.leadingAnchor),
            appSubTitle.trailingAnchor.constraint(equalTo: appTitleContainerView.trailingAnchor, constant: -140),
            appSubTitle.bottomAnchor.constraint(equalTo: appTitleContainerView.bottomAnchor)
        ])
        
        // Configure TenantNameTextField
        tenantNameTextField.placeholder = "Enter your Name"
        tenantNameTextField.borderStyle = .roundedRect
        tenantNameTextField.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        tenantNameTextField.borderRect(forBounds: .zero)
        tenantNameTextField.layer.cornerRadius = 10
        tenantNameTextField.layer.borderColor = UIColor.white.cgColor  // Set white border color
        tenantNameTextField.layer.borderWidth = 1.0
        tenantNameTextField.font = UIFont.systemFont(ofSize: 18)
        tenantNameTextField.translatesAutoresizingMaskIntoConstraints = false
        addDoneButtonOnKeyboard()
        
        // Configure Tenant Room ID TextField
        tenantRoomIdTextField.placeholder = "Room ID here"
        tenantRoomIdTextField.borderStyle = .roundedRect
        tenantRoomIdTextField.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        tenantRoomIdTextField.borderRect(forBounds: .zero)
        tenantRoomIdTextField.layer.cornerRadius = 10
        tenantRoomIdTextField.layer.borderColor = UIColor.white.cgColor  // Set white border color
        tenantRoomIdTextField.layer.borderWidth = 1.0
        tenantRoomIdTextField.font = UIFont.systemFont(ofSize: 18)
        tenantRoomIdTextField.translatesAutoresizingMaskIntoConstraints = false
        addDoneButtonOnKeyboard()
        
        // Configure Submit Button
        submitButton.setTitle("Enter", for: .normal)
        submitButton.backgroundColor = UIColor(red: 245/255, green: 189/255, blue: 69/255, alpha: 1.0)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.layer.cornerRadius = 10
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up layout using a vertical stack view
        let stackView = UIStackView(arrangedSubviews: [appTitleContainerView, tenantNameTextField,tenantRoomIdTextField, submitButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            tenantNameTextField.heightAnchor.constraint(equalToConstant: 50),
            tenantRoomIdTextField.heightAnchor.constraint(equalToConstant: 60),
            
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)

    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector : #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setBackgroundImage() {
        let backgroundImageView = UIImageView(frame: self.view.bounds)
        backgroundImageView.image = UIImage(named: "HomeWallpaper")
        backgroundImageView.contentMode = .scaleAspectFill

        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
    }
    
    // Button Action
    @objc func submitButtonTapped() {
        showFancyLoader()
        guard let tenantName = tenantNameTextField.text, !tenantName.isEmpty else {
            hideLoader()
            showAlert(message: "Please enter a Name")
            return
        }
        guard let tenantId = tenantRoomIdTextField.text, !tenantId.isEmpty else {
            hideLoader()
            showAlert(message: "Please enter a Room ID")
            return
        }
        self.userName = tenantName
        let roomFolderURL = createFolderInDocumentsDirectory(folderName: String(tenantId))
        getFilesAPI = getFilesAPI+tenantId
        downloadAssets(forRoomWithID: tenantId, getFilesAPI: getFilesAPI, roomFolderURL: roomFolderURL!) {
            print("All assets downloaded and ready to use.")
            self.hideLoader()
            let roomViewController = RoomViewController(roomID: tenantId, datasource: self)
            self.navigationController?.pushViewController(roomViewController, animated: true)
        }
    }
    
    func addDoneButtonOnKeyboard() {
        // Create a toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // Create a flexible space item (to push the done button to the right)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Create the done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))

        // Add flexibleSpace and doneButton to the toolbar
        toolbar.setItems([flexibleSpace, doneButton], animated: false)

        // Set the toolbar as the accessory view for the text fields or text views
        tenantRoomIdTextField.inputAccessoryView = toolbar
        tenantRoomIdTextField.inputAccessoryView = toolbar
    }

    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = -180
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.view.frame.origin.y = 0
        }
    }
    
    private func showFancyLoader() {
        // Define the size for the loader view (for example, 200x200)
        let loaderViewSize: CGFloat = 220
        let loaderView = UIView(frame: CGRect(
            x: (view.frame.width - loaderViewSize) / 2,  // Center horizontally
            y: (view.frame.height - loaderViewSize) / 2,  // Center vertically
            width: loaderViewSize,
            height: loaderViewSize
        ))
        loaderView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)  // White background with opacity
        loaderView.layer.cornerRadius = 15  // Optional: Rounded corners
        loaderView.clipsToBounds = true

        // Create the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.frame = CGRect(
            x: (loaderView.frame.width - 50) / 2,  // Center horizontally
            y: (loaderView.frame.height - 50) / 2 - 20,  // Center vertically with a slight offset
            width: 50, height: 50  // Size of the indicator
        )
        activityIndicator.startAnimating()

        // Create the loading message label
        let messageLabel = UILabel()
        messageLabel.text = loadingMessages[currentMessageIndex]  // Start with the first message
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
        messageLabel.frame = CGRect(
            x: 10,
            y: activityIndicator.frame.maxY + 10,  // Position below the activity indicator
            width: loaderView.frame.width - 20,
            height: 30
        )

        // Add subviews
        loaderView.addSubview(activityIndicator)
        loaderView.addSubview(messageLabel)
        view.addSubview(loaderView)

        // Store references for later use (to hide the loader)
        self.activityIndicator = activityIndicator
        self.loadingView = loaderView
        self.loadingMessageLabel = messageLabel
        startMessageRotation()
    }

    private func startMessageRotation() {
        // Update the message every 1.5 seconds
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            // Increment the message index
            self.currentMessageIndex += 1
            
            // Loop back to the first message when we've shown all of them
            if self.currentMessageIndex >= self.loadingMessages.count {
                self.currentMessageIndex = 0
            }
            
            // Update the label with the new message
            self.loadingMessageLabel?.text = self.loadingMessages[self.currentMessageIndex]
        }
    }

    // Function to hide the loader
    private func hideLoader() {
        activityIndicator?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingMessageLabel = nil
        activityIndicator = nil
        loadingView = nil
        currentMessageIndex = 0  // Reset index for the next time the loader is shown
    }
    
    func createFolderInDocumentsDirectory(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderURL = documentsDirectory.appendingPathComponent(folderName)
            
            // Check if the main folder already exists, if not, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    print("Main folder created at: \(folderURL.path)")
                } catch {
                    print("Failed to create folder: \(error)")
                    return nil
                }
            }
            
            // Create subfolder for images inside the main folder
            let imagesFolderURL = folderURL.appendingPathComponent("Images")
            if !fileManager.fileExists(atPath: imagesFolderURL.path) {
                do {
                    try fileManager.createDirectory(at: imagesFolderURL, withIntermediateDirectories: true, attributes: nil)
                    print("Images subfolder created at: \(imagesFolderURL.path)")
                } catch {
                    print("Failed to create Images subfolder: \(error)")
                    return nil
                }
            }
            
            // Create subfolder for 3D models inside the main folder
            let modelsFolderURL = folderURL.appendingPathComponent("3DModels")
            if !fileManager.fileExists(atPath: modelsFolderURL.path) {
                do {
                    try fileManager.createDirectory(at: modelsFolderURL, withIntermediateDirectories: true, attributes: nil)
                    print("3DModels subfolder created at: \(modelsFolderURL.path)")
                } catch {
                    print("Failed to create 3DModels subfolder: \(error)")
                    return nil
                }
            }
            
            return folderURL
        }
        return nil
    }
    
    func downloadAssets(forRoomWithID roomID: String, getFilesAPI: String, roomFolderURL: URL, completion: @escaping () -> Void) {
        
        fetchModelData(from: getFilesAPI) { markerURLs, modelURLs in
            print("Marker URLs: \(markerURLs)")
            print("Model URLs: \(modelURLs)")

            let downloadGroup = DispatchGroup()

            // Download the 3D models
            downloadGroup.enter()
            self.downloadMultipleUSDZModels(from: modelURLs, to: roomFolderURL.appendingPathComponent("3DModels")) { loadedNodes in
                print("3D Models loaded:")
                for node in loadedNodes {
                    print("Loaded model node: \(node)")
                }
                downloadGroup.leave() // Models download complete
            }

            // Download the marker images
            downloadGroup.enter()
            self.downloadMultipleMarkerImages(from: markerURLs, to: roomFolderURL.appendingPathComponent("Markers")) { referenceImages in
                print("Marker Images loaded:")
                for image in referenceImages {
                    print("Loaded marker image: \(image.name ?? "Unknown")")
                }
                downloadGroup.leave()
            }
//            if self.downloded3DModels.isEmpty && self.referenceImages.isEmpty{
//                print("All assets **NOT** downloaded (models and markers)")
//                DispatchQueue.main.async{
//                    self.hideLoader()
//                    self.showAlert(message: "No Room Found on this ID. Kindly try with a different RoomIDcreate")
//                 //   return
//                }
//            }
           // else{
                downloadGroup.notify(queue: .main) {
                    print("All assets downloaded (models and markers).")
                    completion()
                }
         //   }
        }
    }
    
    func fetchModelData(from apiURL: String, completion: @escaping ([String], [String]) -> Void) {
        guard let url = URL(string: apiURL) else {
            print("Invalid API URL")
            completion([], [])
            return
        }

        // Create a URLSession data task to fetch the JSON response
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error fetching data: \(error)")
                completion([], [])
                return
            }

            // Ensure there is data in the response
            guard let data = data else {
                print("No data returned from API")
                completion([], [])
                return
            }

            do {
                // Parse the JSON response
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let markers = json["markers"] as? [String], // Extract marker names
                   let models = json["models"] as? [String] {  // Extract model names

                    // Base URL to append file names
                    let baseURL = self.downloadModelsAPI

                    // Filter only .jpg files for markers and .zip for models
                    let filteredMarkerURLs = markers.filter { $0.hasSuffix(".jpg") || $0.hasSuffix(".png") }
                        .map { baseURL + $0 }
                    
                    let filteredModelURLs = models.filter { $0.hasSuffix(".zip") || $0.hasSuffix(".usdz") }
                        .map {$0 }

                    // Return the filtered arrays through the completion handler
                    completion(filteredMarkerURLs, filteredModelURLs)
                } else {
                    print("Invalid JSON structure")
                    completion([], [])
                }
            } catch {
                print("Error parsing JSON: \(error)")
                completion([], [])
            }
        }

        // Start the URL session task
        task.resume()
    }
    
    func downloadMultipleUSDZModels(from urls: [String], to destinationFolder: URL, completion: @escaping ([SCNNode]) -> Void) {
        let fileManager = FileManager.default

        // Ensure the destination folder exists
        if !fileManager.fileExists(atPath: destinationFolder.path) {
            do {
                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
                print("Destination folder created at: \(destinationFolder.path)")
            } catch {
                print("Failed to create destination folder: \(error)")
                completion([])
                return
            }
        }

        // Create a DispatchGroup to track all download tasks
        let downloadGroup = DispatchGroup()

        // Array to hold the SCNNode objects for the 3D models
        var downloadedNodes: [SCNNode] = []

        // Iterate through the URLs and start downloading each file
        for fileName in urls {
            let urlString = downloadModelsAPI + fileName
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                continue
            }

            let destinationURL = destinationFolder.appendingPathComponent(fileName)

            // Check if the file already exists
            if fileManager.fileExists(atPath: destinationURL.path) {
                print("File already exists at: \(destinationURL.path)")
                
                // Load the existing 3D model from the file
                if let node = load3DModel(from: destinationURL) {
                    node.name = (fileName as NSString?)?.deletingPathExtension
                    downloadedNodes.append(node)
                }
                continue
            }

            // Enter the DispatchGroup before starting the download task
            downloadGroup.enter()

            // Create and start the download task
            let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
                if let error = error {
                    print("Download error: \(error)")
                    downloadGroup.leave() // Leave the group on error
                    return
                }

                guard let tempURL = tempURL else {
                    print("No file URL for: \(urlString)")
                    downloadGroup.leave() // Leave the group if there's no file
                    return
                }

                // Move the file from the temp location to the destination folder
                do {
                    try fileManager.moveItem(at: tempURL, to: destinationURL)
                    print("File downloaded to: \(destinationURL.path)")

                    // Load the 3D model from the downloaded file and add to the nodes array
                    if let node = self.load3DModel(from: destinationURL) {
                        node.name = (fileName as NSString?)?.deletingPathExtension
                        downloadedNodes.append(node)
                    }
                } catch {
                    print("File move error: \(error)")
                }

                // Leave the DispatchGroup when the download task is complete
                downloadGroup.leave()
            }

            task.resume() // Start the download task
        }

        // Notify when all download tasks have completed
        downloadGroup.notify(queue: .main) {
            print("All downloads completed")
            self.downloded3DModels = downloadedNodes
            completion(downloadedNodes) // Return all the loaded SCNNodes
        }
    }
    
    func load3DModel(from fileURL: URL) -> SCNNode? {
        do {
            let scene = try SCNScene(url: fileURL, options: nil)
            if let modelNode = scene.rootNode.childNodes.first {
                return modelNode // Return the first node (your 3D model)
            }
        } catch {
            print("Error loading 3D model: \(error)")
        }
        return nil
    }
    
    func getFilesForCurrentRoomID(folderName: String) -> URL? {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let folderURL = documentsDirectory.appendingPathComponent(folderName)
            
            // Check if the main folder already exists, if not, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                    print("Main folder created at: \(folderURL.path)")
                } catch {
                    print("Failed to create folder: \(error)")
                    return nil
                }
            }
            
            let imagesFolderURL = folderURL.appendingPathComponent("Images")
            if !fileManager.fileExists(atPath: imagesFolderURL.path) {
                do {
                    try fileManager.createDirectory(at: imagesFolderURL, withIntermediateDirectories: true, attributes: nil)
                    print("Images subfolder created at: \(imagesFolderURL.path)")
                } catch {
                    print("Failed to create Images subfolder: \(error)")
                    return nil
                }
            }
            
            let modelsFolderURL = folderURL.appendingPathComponent("3DModels")
            if !fileManager.fileExists(atPath: modelsFolderURL.path) {
                do {
                    try fileManager.createDirectory(at: modelsFolderURL, withIntermediateDirectories: true, attributes: nil)
                    print("3DModels subfolder created at: \(modelsFolderURL.path)")
                } catch {
                    print("Failed to create 3DModels subfolder: \(error)")
                    return nil
                }
            }
            
            return folderURL
        }
        return nil
    }
    
    func downloadMultipleMarkerImages(from urls: [String], to destinationFolder: URL, completion: @escaping ([ARReferenceImage]) -> Void) {
        
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: destinationFolder.path) {
            do {
                try fileManager.createDirectory(at: destinationFolder, withIntermediateDirectories: true, attributes: nil)
                print("Destination folder created at: \(destinationFolder.path)")
            } catch {
                print("Failed to create destination folder: \(error)")
                completion([])
                return
            }
        }

        let downloadGroup = DispatchGroup()

        var downloadedReferenceImages: [ARReferenceImage] = []

        for urlString in urls {
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL: \(urlString)")
                continue
            }

            let fileName = url.lastPathComponent
            let destinationURL = destinationFolder.appendingPathComponent(fileName)

            if fileManager.fileExists(atPath: destinationURL.path) {
                print("File already exists at: \(destinationURL.path)")
                
                if let referenceImage = loadReferenceImage(from: destinationURL) {
                    downloadedReferenceImages.append(referenceImage)
                }
                continue
            }

            downloadGroup.enter()

            let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
                if let error = error {
                    print("Download error: \(error)")
                    downloadGroup.leave()
                    return
                }

                guard let tempURL = tempURL else {
                    print("No file URL for: \(urlString)")
                    downloadGroup.leave()
                    return
                }

                do {
                    try fileManager.moveItem(at: tempURL, to: destinationURL)
                    print("File downloaded to: \(destinationURL.path)")

                    if let referenceImage = self.loadReferenceImage(from: destinationURL) {
                        downloadedReferenceImages.append(referenceImage)
                    }
                } catch {
                    print("File move error: \(error)")
                }

                downloadGroup.leave()
            }

            task.resume()
        }

        downloadGroup.notify(queue: .main) {
            print("All marker downloads completed")
            self.referenceImages = downloadedReferenceImages
            completion(downloadedReferenceImages)
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func loadReferenceImage(from fileURL: URL) -> ARReferenceImage? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("File does not exist at: \(fileURL.path)")
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)  // Attempt to read the file data
            if let image = UIImage(data: data) {
                print("Successfully loaded image.")
            } else {
                print("The file is not a valid image.")
            }
        } catch {
            // Handle the error if file reading fails
            print("Failed to read file: \(error.localizedDescription)")
        }
        
        if let image = UIImage(contentsOfFile: fileURL.path),
           let cgImage = image.cgImage {

            let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: 0.2) // Set appropriate physical width
            referenceImage.name = fileURL.lastPathComponent
            return referenceImage
        } else {
            print("Failed to load image from URL: \(fileURL)")
        }
        return nil
    }
}

extension HomeScreenViewController: RoomAssetsProtocol{
    func getUserName() -> String {
        return self.userName
    }
    
    func getReferenceImages() -> [ARReferenceImage] {
        return self.referenceImages
    }
    
    func get3DModels() -> [SCNNode] {
        return self.downloded3DModels
    }
    
    
}


