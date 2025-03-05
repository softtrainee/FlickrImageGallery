//
//  FlickrAPIManager.swift
//  FlickrImageGallery
//
//  Created by Mohit Gupta on 05/03/25.
//

import UIKit

class FlickrAPIManager {
    static let shared = FlickrAPIManager()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    // MARK: - Fetch Images from Flickr API
    func fetchImages(searchTerm: String, completion: @escaping ([FlickrImage]?, Error?) -> Void) {
        let urlString = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1&tags=\(searchTerm)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No Data", code: -1, userInfo: nil))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {
                    var images: [FlickrImage] = []
                    let group = DispatchGroup()
                    
                    for item in items {
                        if let media = item["media"] as? [String: String],
                           let imageUrlString = media["m"],
                           let imageUrl = URL(string: imageUrlString) {
                            group.enter()
                            self.loadImage(from: imageUrl) { image in
                                if let image = image {
                                    let aspectRatio = image.size.width / image.size.height
                                    images.append(FlickrImage(image: image, aspectRatio: aspectRatio))
                                }
                                group.leave()
                            }
                        }
                    }
                    
                    group.notify(queue: .main) {
                        completion(images, nil)
                    }
                } else {
                    completion(nil, NSError(domain: "Invalid JSON", code: -1, userInfo: nil))
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // MARK: - Load and Cache Image
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            
            self.cache.setObject(image, forKey: url.absoluteString as NSString)
            completion(image)
        }.resume()
    }
}
