//
//  ImagePostViewController.swift
//  ImageFilterEditor
//
//  Created by Wyatt Harrell on 5/4/20.
//  Copyright © 2020 Wyatt Harrell. All rights reserved.
//

import UIKit
import CoreImage

enum FilterTypes: Int {
    case exposure
    case vibrance
    case vignette
    case sepia
    case motionBlur
}

class ImagePostViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var adjustmentSlider: UISlider!
    @IBOutlet weak var secondAdjustmentSlider: UISlider!
    @IBOutlet weak var saveButton: UIButton!
    
    // MARK: - Properties
    let context = CIContext(options: nil)
    var filterType: FilterTypes = .exposure
    let effectNames: [String] = ["Exposure", "Vibrance", "Vignette", "Sepia Tone", "Motion Blur"]
    let effectImages: [UIImage] = [UIImage(systemName: "sun.max")!, UIImage(systemName: "sunrise")!, UIImage(systemName: "smallcircle.circle")!, UIImage(systemName: "eyedropper.halffull")!, UIImage(systemName: "slider.horizontal.3")!]
    
    var originalImage: UIImage? {
        didSet {
            // resize the scaledImage and set it
            guard let originalImage = originalImage else { return }
            // Height and width
            var scaledSize = imageView.bounds.size
            let scale = UIScreen.main.scale  // 1x, 2x, or 3x
            scaledSize = CGSize(width: scaledSize.width * scale, height: scaledSize.height * scale)
            print("scaled size: \(scaledSize)")
            
            scaledImage = originalImage.imageByScaling(toSize: scaledSize)
        }
    }
    var scaledImage: UIImage? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        secondAdjustmentSlider.isHidden = true
        adjustmentSlider.isHidden = true
        nameLabel.isHidden = true
        saveButton.isHidden = true
    }
    
    // MARK: - IBActions
    @IBAction func selectPhotoButtonTapped(_ sender: Any) {
        presentImagePickerController()
    }
    
    @IBAction func adjustmentSliderChanged(_ sender: Any) {
        updateViews(withAdjustment: true)
    }
    
    @IBAction func secondAdjustmentSliderChanged(_ sender: Any) {
        updateViews(withAdjustment: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        scaledImage = imageView.image
    }
    
    // MARK: - Private Methods
    private func presentImagePickerController() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("Error: The photo library is not available")
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateViews(withAdjustment: Bool = false) {
        if let scaledImage = scaledImage {
            
            if withAdjustment {
                if filterType.rawValue == 0 {
                    imageView.image = adjustExposure(scaledImage)
                } else if filterType.rawValue == 1 {
                    imageView.image = adjustVibrance(scaledImage)
                } else if filterType.rawValue == 2 {
                    imageView.image = adjustVignette(scaledImage)
                } else if filterType.rawValue == 3 {
                    imageView.image = adjustSepia(scaledImage)
                } else if filterType.rawValue == 4 {
                    imageView.image = adjustMotionBlur(scaledImage)
                }
            } else {
                imageView.image = scaledImage
            }
            
        } else {
            imageView.image = nil
        }
    }
    
    private func adjustExposure(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIExposureAdjust")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputEVKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVibrance(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIVibrance")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputAmountKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustVignette(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIVignetteEffect")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputIntensityKey)
        filter.setValue(secondAdjustmentSlider.value, forKey: kCIInputRadiusKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustSepia(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CISepiaTone")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputIntensityKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func adjustMotionBlur(_ image: UIImage) -> UIImage? {
        
        // UIImage -> CGImage -> CIImage
        guard let cgImage = image.cgImage else { return nil }
        let ciImage = CIImage(cgImage: cgImage)
                
        // Filter
        let filter = CIFilter(name: "CIMotionBlur")!
        
        // Setting values / getting values from Core Image
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(adjustmentSlider.value, forKey: kCIInputRadiusKey)
        filter.setValue(secondAdjustmentSlider.value, forKey: kCIInputAngleKey)
        
        // CIImage -> CGImage -> UIImage
        
        guard let outputCIImage = filter.outputImage else { return nil }
        
        // Render the image (do image processing here). Recipe needs to be used on image now.
        guard let outputCGImage = context.createCGImage(outputCIImage, from: CGRect(origin: .zero, size: image.size)) else {
            return nil
        }
        
        return UIImage(cgImage: outputCGImage)
    }
    
    private func showFilter(for index: IndexPath) {
        adjustmentSlider.isHidden = false
        nameLabel.isHidden = false
        saveButton.isHidden = false
        
        nameLabel.text = effectNames[index.row]
        filterType = FilterTypes(rawValue: index.item)!
        imageView.image = scaledImage

        if index.item == 0 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 10
            adjustmentSlider.minimumValue = -10
        } else if index.item == 1 {
            secondAdjustmentSlider.isHidden = true
            
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = -1
        } else if index.item == 2 {
            secondAdjustmentSlider.isHidden = false

            // Intensity
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = -1
            
            // Radius
            secondAdjustmentSlider.value = 0
            secondAdjustmentSlider.maximumValue = 2000
            secondAdjustmentSlider.minimumValue = 0
        } else if index.item == 3 {
            secondAdjustmentSlider.isHidden = true

            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 1
            adjustmentSlider.minimumValue = 0
        } else if index.item == 4 {
            secondAdjustmentSlider.isHidden = false

            // Radius
            adjustmentSlider.value = 0
            adjustmentSlider.maximumValue = 100
            adjustmentSlider.minimumValue = 0
            
            // Angle
            secondAdjustmentSlider.value = 0
            secondAdjustmentSlider.maximumValue = 3.141592653589793
            secondAdjustmentSlider.minimumValue = -3.141592653589793
        }
    }

}

extension ImagePostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effectNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EffectCell", for: indexPath) as? EffectCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 15
        cell.nameLabel.text = effectNames[indexPath.item]
        cell.effectImage.image = effectImages[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showFilter(for: indexPath)
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            originalImage = image
        }
        
        picker.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
