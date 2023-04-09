//
//  ShakeItPhotoViewController+Ext.swift
//  ShakeItPhoto
//
//  Created by Cricket on 10/12/22.
//

import Foundation
import AVFoundation


@objc extension ShakeItPhotoViewController {
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
}
