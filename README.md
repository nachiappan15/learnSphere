# LearnSphere 

Revolutionizing the Way Students Visualize and Interact with Educational Content

Overview

LearnSphere is an innovative educational platform designed to make learning more interactive, visual, and engaging for students. LearnSphere enables students to visualize complex concepts and models in a 3D space, improving comprehension and retention.

Whether you’re a teacher looking to create immersive lessons or a student eager to explore new learning methods, LearnSphere provides the tools and environment to bring learning into the 21st century.

Key Features ✨

	•	AR-Powered Learning: Bring 3D models to life using Augmented Reality. Students can interact with these models in real-time, rotating and annotating them for better understanding.
	•	Collaborative Learning Spaces: With unique room IDs, multiple students can join the same room, view the same 3D models, and engage in discussions or collaborative problem-solving.
	•	Real-Time Chat: Chat with other room participants using an integrated chat feature powered by Firebase Firestore.
	•	Intuitive Room Setup: Teachers or admins can easily set up rooms with custom 3D models and reference images, providing an easy-to-navigate interface for students.
	•	Annotation Feature: Tap and hold on any 3D model to add annotations. This enables real-time feedback and collaboration on shared learning content.

How It Works 🔧

Web App (Admin/Teacher Portal)

	•	Admins, authors, or teachers can create a new room with a unique room ID and upload the necessary assets (3D models and reference images).
	•	The assets are managed on the web portal and are stored on a file server with the corresponding room ID.
	•	Admins can edit or delete the assets as required, and all files are ready for student use upon submission.

Mobile App (iOS)

	1.	Room Entry: Students enter the unique room ID provided by their teacher to access the associated learning materials.
	2.	Download of Assets: The app automatically downloads the required assets (3D model, reference image) when a valid room ID is entered. These assets are cleared once the student exits the room.
	3.	Interactive Room Home: After entering the room, students are taken to the room’s home screen, which includes options for:
	•	Chatting with other room participants.
	•	Accessing the AR scanner to scan reference images.
	•	Viewing and interacting with the 3D model.
	4.	Engaging 3D Visualization: Once a reference image is scanned, the associated 3D model is loaded, allowing students to view, rotate, and interact with it.
	•	Annotation Feature: Students can tap and hold on specific areas of the 3D model to add annotations or comments, fostering collaborative learning.

Technical Implementation ⚙️

	•	iOS App: Built using Swift and UIKit, with ARKit integration for AR functionality.
	•	Web App (Frontend): Built with React for a seamless and dynamic user experience.
	•	Backend: Java-based backend to manage user authentication, room setups, and asset management.
	•	Database: MySQL is used for storing user data, room details, and asset metadata.
	•	Firebase Firestore: Real-time chat feature is powered by Firebase Firestore, enabling instant messaging between users in the same room.
	•	NGROk: Used for API web hosting during the development phase.
