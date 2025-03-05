//
//  ViewController.swift
//  FlickrImageGallery
//
//  Created by Mohit Gupta on 05/03/25.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Properties
    private let viewModel = FlickrViewModel()
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupViewModel()
        fetchImages()
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshImages), for: .valueChanged)
    }
    
    private func setupViewModel() {
        viewModel.onImagesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView?.reloadData()
                self?.refreshControl.endRefreshing()
                self?.activityIndicator?.stopAnimating()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showError(message: errorMessage)
                self?.refreshControl.endRefreshing()
                self?.activityIndicator?.stopAnimating()
            }
        }
    }
    
    // MARK: - Fetch Images
    private func fetchImages() {
        activityIndicator?.startAnimating()
        viewModel.fetchImages()
    }
    
    @objc private func refreshImages() {
        viewModel.refreshImages()
    }
    
    // MARK: - Error Handling
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as? ImageCell
        let flickrImage = viewModel.images[indexPath.item]
        cell?.configure(with: flickrImage.image)
        return cell ?? ImageCell()
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 16
        let collectionViewWidth = collectionView.frame.width
        let totalPadding = padding * 3
        let availableWidth = collectionViewWidth - totalPadding
        let cellWidth = availableWidth / 2
        
        let flickrImage = viewModel.images[indexPath.item]
        let cellHeight = cellWidth / flickrImage.aspectRatio
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}


import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView?
    @IBOutlet weak var imageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCardView()
    }
    
    private func setupCardView() {
        containerView?.layer.cornerRadius = 10
        containerView?.layer.masksToBounds = true
        containerView?.layer.shadowColor = UIColor.black.cgColor
        containerView?.layer.shadowOpacity = 0.3
        containerView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView?.layer.shadowRadius = 4
        containerView?.layer.masksToBounds = false
    }
    
    func configure(with image: UIImage) {
        imageView?.image = image
    }
}
