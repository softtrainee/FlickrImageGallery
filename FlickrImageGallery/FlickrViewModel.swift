//
//  FlickrViewModel.swift
//  FlickrImageGallery
//
//  Created by Mohit Gupta on 05/03/25.
//

import UIKit

class FlickrViewModel {
    // MARK: - Properties
    var images: [FlickrImage] = []
    var onImagesUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    // MARK: - Fetch Images
    func fetchImages(searchTerm: String = "nature") {
        FlickrAPIManager.shared.fetchImages(searchTerm: searchTerm) { [weak self] images, error in
            guard let self = self else { return }
            
            if let error = error {
                self.onError?(error.localizedDescription)
                return
            }
            
            if let images = images {
                self.images = images
                self.onImagesUpdated?()
            }
        }
    }
    
    // MARK: - Pull-to-Refresh
    func refreshImages(searchTerm: String = "nature") {
        fetchImages(searchTerm: searchTerm)
    }
}
