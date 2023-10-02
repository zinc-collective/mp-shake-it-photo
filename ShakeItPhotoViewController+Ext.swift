//
//  ShakeItPhotoViewController+Ext.swift
//  ShakeItPhoto
//
//  Created by Cricket on 10/12/22.
//

import Foundation
import AVFoundation
import UIKit
import UniformTypeIdentifiers


@objc extension ShakeItPhotoViewController {
    @objc func setToolbarVisibility(_ state: Bool) -> Void {
        let duration = 0.3
        
        UIView.animate(withDuration: duration, animations: { [weak self, state] in
            self?.toolbar.alpha = state ? 1.0 : 0.0
        })
    }
    
    @objc func animateDevelopment(_ duration: TimeInterval) {
//        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {[weak self] in
//            self._undevelopedView.alpha =  0.001;
//        }, completion: { finished in
//            print("###---> \(finished)")
//            self._undevelopedView.removeFromSuperview()
//            self._undevelopedView = nil
//            self.stopTrackingAcceleration()
//        })
    }

    
    // https://developer.apple.com/documentation/avfoundation/capture_setup/requesting_authorization_to_capture_and_save_media
    @objc func checkAndRequestPermissions() async -> Void {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        print("###---> permissions status: \(status)")
        guard status == .authorized else {
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                await AVCaptureDevice.requestAccess(for: .video)
            }
            return
        }
    }
    
    @objc func isAuthorized() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        // Determine if the user previously authorized camera access.
        return status == .authorized
        
    }
    
    @objc func basicImageShare(withImage image: UIImage) -> Void {
        let items = [image]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
}

@objc extension ShakeItPhotoImageProcessor {
    @objc func modernWriteProcessedImageToPhotoLibrary(image: CGImage) -> Void {
        
    }
    
    @objc func modernWriteOriginalImageToPhotoLibrary(image: UIImage) -> Void {
        
    }
}

// MARK: - NSItemProvider to support WebP format (PNG-based and JPEG-based)
@objc extension NSItemProvider {
    enum NSItemProviderLoadImageError: Error {
        case unexpectedImageType
    }
    
    @objc func loadImage(completion: @escaping (UIImage?, Error?) -> Void) {
        
        if canLoadObject(ofClass: UIImage.self) {
            
            // Handle UIImage type
            loadObject(ofClass: UIImage.self) { image, error in
               
                guard let resultImage = image as? UIImage else {
                    completion(nil, error)
                    return
                }
                
                completion(resultImage, error)
            }
            
        } else if hasItemConformingToTypeIdentifier(UTType.webP.identifier) {
            
            // Handle WebP Image
            loadDataRepresentation(forTypeIdentifier: UTType.webP.identifier) { data, error in
                
                guard let data,
                      let webpImage = UIImage(data: data) else {
                    completion(nil, error)
                    return
                }
                
                completion(webpImage, error)
            }
            
        } else {
            completion(nil, NSItemProviderLoadImageError.unexpectedImageType)
        }
    }
}
