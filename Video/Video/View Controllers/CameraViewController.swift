//
//  CameraViewController.swift
//  Video
//
//  Created by Wyatt Harrell on 5/6/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class CameraViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var cameraView: CameraPreviewView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    // MARK: - Properties
    lazy private var captureSession = AVCaptureSession()
    lazy private var fileOutput = AVCaptureMovieFileOutput()
    var locationManager: CLLocationManager?
    var recordedVideoURL: URL?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraView.videoPlayerView.videoGravity = .resizeAspectFill
        setUpCaptureSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    // MARK: - Private Methods
    private func updateViews() {
        recordButton.isSelected = fileOutput.isRecording
        if fileOutput.isRecording {
            dismissButton.isEnabled = false
        } else {
            dismissButton.isEnabled = true
        }
    }
    
    private func setUpCaptureSession() {
        // Add inputs
        captureSession.beginConfiguration()
        // Camera inputs
        let camera = bestCamera()
        
        guard let cameraInput = try? AVCaptureDeviceInput(device: camera),
                                     captureSession.canAddInput(cameraInput) else {
            fatalError("Error adding camera to capture session")
        }
        
        captureSession.addInput(cameraInput)
        
        if captureSession.canSetSessionPreset(.hd1920x1080) {
            captureSession.sessionPreset = .hd1920x1080
        } // Will default to high quality otherwise
        
        // Mic inputs
        
        // Add outputs
        guard captureSession.canAddOutput(fileOutput) else {
            fatalError("Error: Cannot save movie")
        }
        captureSession.addOutput(fileOutput)
        
        captureSession.commitConfiguration()
        cameraView.session = captureSession
    }
    
    private func bestCamera() -> AVCaptureDevice {
        // FUTURE: Togggle between front/back with a button
        
        // Ultra-wide lens (iPhone 11 Pro + Pro Max on back)
        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            return ultraWideCamera
        }
        // Wide angle (Available on any iPhone - front/back)
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        
        // No cameras present (simulator)
        fatalError("No camera available - are you on a simulator?")
    }
    
    private func toggleRecord() {
        if fileOutput.isRecording {
            fileOutput.stopRecording()
        } else {
            recordedVideoURL = newRecordingURL()
            fileOutput.startRecording(to: recordedVideoURL!, recordingDelegate: self)
        }
    }
     
     /// Creates a new file URL in the documents directory
     private func newRecordingURL() -> URL {
         let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

         let formatter = ISO8601DateFormatter()
         formatter.formatOptions = [.withInternetDateTime]

         let name = formatter.string(from: Date())
         let fileURL = documentsDirectory.appendingPathComponent(name).appendingPathExtension("mov")
         return fileURL
     }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PresentVideoSegue" {
            guard let ViewRecordingVC = segue.destination as? ViewRecordingViewController else { return }
            
            ViewRecordingVC.recordingURL = recordedVideoURL
            ViewRecordingVC.locationManager = locationManager
        }
    }
    
    // MARK: - IBActions
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        toggleRecord()
    }
}


extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error saving video: \(error)")
        } else {
            performSegue(withIdentifier: "PresentVideoSegue", sender: self)
        }
        updateViews()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print("started recording \(fileURL)")
        updateViews()
    }
}
