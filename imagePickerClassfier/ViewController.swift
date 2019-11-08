//
//  ViewController.swift
//  imagePickerClassfier
//
//  Created by joon-ho kil on 2019/11/08.
//  Copyright © 2019 joon-ho kil. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var identifier: UILabel!
    @IBOutlet weak var confidence: UILabel!
    
    @IBAction func imagePick(_ sender: Any) {
        present(imagePicker, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        imagePicker.modalPresentationStyle = .fullScreen
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else { return }
        self.pickedImage.image = image
        guard let ciImage = CIImage(image: image) else { return }
        coreMLProcessing(image: ciImage)
    }
}

extension ViewController {
    func coreMLProcessing(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: newEmojiAndCat().model) else {
            fatalError("Model을 로드할 수 없습니다.")
        }
        
        let request = VNCoreMLRequest(model: model){
            (finishedReq, err) in
            guard let results = finishedReq.results as? [VNRecognizedObjectObservation] else { return }
            guard let objectObservation = results.first?.labels.first else {
                DispatchQueue.main.async {
                    self.identifier.text = "인식된 물체 없음"
                    self.confidence.text = "0"
                }
                return
            }
            
            DispatchQueue.main.async {
                self.identifier.text = objectObservation.identifier
                self.confidence.text = String(objectObservation.confidence)
            }
        }
        
        try? VNImageRequestHandler(ciImage: image, options: [:]).perform([request])
    }
}
