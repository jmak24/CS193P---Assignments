//
//  ImageGalleryViewController.swift
//  ImageGallery
//
//  Created by Jon Mak on 2019-01-28.
//  Copyright © 2019 Jon Mak. All rights reserved.
//

import UIKit

class ImageGalleryViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1776998043, green: 0.1782446504, blue: 0.1848969758, alpha: 0.7023223459)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)]

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collectionView?.collectionViewLayout = layout
    }
    
    func reloadImages() {
        self.collectionView?.reloadData()
    }
    
    // Mark: - Image Collection View
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.addInteraction(UIDropInteraction(delegate: self))
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
            
            let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomGallery(_:)))
            collectionView.addGestureRecognizer(pinch)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Expand Image" {
            if let imageCell = sender as? ImageCollectionViewCell,
                let indexPath = collectionView?.indexPath(for: imageCell),
                let ivc = segue.destination as? ImageViewController {
                    ivc.imageURL = imageCollection[indexPath.item].url
            }
        }
    }
    
    var flowLayout: UICollectionViewFlowLayout? {
        return collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
    }
    
    @objc func zoomGallery(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed:
            scale *= gesture.scale
            gesture.scale = 1.0
        default: break
        }
    }
    
    var boundsCollectionWidth: CGFloat { return ((collectionView?.bounds.width)!) }
    var gapItems: CGFloat { return ((flowLayout?.minimumInteritemSpacing)!) * CGFloat(2) }
    var gapSections: CGFloat { return (flowLayout?.sectionInset.right)! * 2.0 }
    
    var predefinedWidth: CGFloat {
        let width = floor((boundsCollectionWidth - gapItems - gapSections)
            / CGFloat(3)) * scale
        return min (max (width, boundsCollectionWidth * 0.10), boundsCollectionWidth - gapSections)
    }
    
    var scale: CGFloat = 1.0 {
        didSet {
            flowLayout?.invalidateLayout()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = predefinedWidth
        let aspectRatio = CGFloat(imageCollection[indexPath.item].aspectRatio)
        return CGSize(width: width , height: width / aspectRatio)
    }
    
    // Mark: - Model / CollectionView Data Source
    
    var imageCollection = [ImageModel]() {
        didSet {
            modelUpdateHandler?(imageCollection)
        }
    }
    
    // Mark: - Handler to update the GalleryDocument's Model
    
    var modelUpdateHandler: ((_ imageInfo: [ImageModel]) -> Void)?
    
    // Mark: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.imageURL = imageCollection[indexPath.item].url
            imageCell.aspectRatio = imageCollection[indexPath.item].aspectRatio
        }
        return cell
    }
    
    // MARK: - UICollectionViewDragDelegate

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let imageCell = (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell), let image = imageCell.imageView.image {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: image))
            dragItem.localObject = imageCollection[indexPath.item]
            return [dragItem]
        } else {
            return []
        }
    }
    
    // MARK: - UICollectionViewDropDelegate
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        
        if isSelf {
            return session.canLoadObjects(ofClass: UIImage.self)
        } else {
            return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: NSURL.self)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // if dragged item was dragged locally we want to move it, else copy the item
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    var imageFetcher: ImageFetcher?
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath { // Dragged locally
                if let imageInfo = item.dragItem.localObject as? ImageModel {
                    collectionView.performBatchUpdates({
                        imageCollection.remove(at: sourceIndexPath.item)
                        imageCollection.insert(imageInfo, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            } else { // Dragged from another app
                let placeholderContext = coordinator.drop(
                    item.dragItem,
                    to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell")
                )
                
                var imageURLLocal: URL?
                var aspectRatioLocal: Double?
                
                // Load UIImage
                item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let image = provider as? UIImage {
                            aspectRatioLocal = Double(image.size.width) / Double(image.size.height)
                        }
                    }
                }
                
                // Load URL
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = provider as? URL {
                            imageURLLocal = url.imageURL
                            if imageURLLocal != nil, aspectRatioLocal != nil {
                                placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                    let item = ImageModel(url: imageURLLocal!, aspectRatio: aspectRatioLocal!)
                                    self.imageCollection.insert(item, at: insertionIndexPath.item)
                                })
                            } else {
                                placeholderContext.deletePlaceholder()
                            }
                        }
                    }
                }
            }
        }
    }
}

