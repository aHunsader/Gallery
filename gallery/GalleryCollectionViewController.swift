//
//  GalleryCollectionViewController.swift
//  gallery
//
//  Created by Alex Hunsader on 4/9/18.
//  Copyright © 2018 Alex Hunsader. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDropDelegate, UICollectionViewDelegateFlowLayout {
    
    
    static let WIDTH = 100.0
    var images = Gallery()
    var im_galleries = Image_galleries()
    var id = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        collectionView?.dropDelegate = self
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.arr.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
    
        if let im = cell as? ImageCollectionViewCell {
            fetch(indexPath: indexPath, im: im)
        }
    
        return cell
    }
    
    private func fetch(indexPath: IndexPath, im: ImageCollectionViewCell) {
        let url = images.arr[indexPath.row].url.imageURL
        DispatchQueue.global(qos: .userInitiated).async {
            if let urlContents = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let temp = UIImage(data: urlContents)
                    im.image.image = temp
                }
            } else {
                let alert = UIAlertController(title: "Bad source", message: "The image could not be downloaded. Would you like to keep the image or remove it?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Keep it", style: .default))
                alert.addAction(UIAlertAction(title: "Remove it", style: .destructive){ action in
                    self.remove_image(url: self.images.arr[indexPath.row].url)
                    Image_galleries.save(id: self.id, gallery: self.images)
                })
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat((GalleryCollectionViewController.WIDTH / images.arr[indexPath.row].width) * images.arr[indexPath.row].height)
        return CGSize(width: CGFloat(GalleryCollectionViewController.WIDTH), height: height);
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        print("hello")
        return session.canLoadObjects(ofClass: UIImage.self) && session.canLoadObjects(ofClass: NSURL.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destination = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        
        for item in coordinator.items {
            let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destination, reuseIdentifier: "ImageCell"))
            var height: CGFloat = 0.0
            var width: CGFloat = 0.0
            item.dragItem.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let im = image as? UIImage {
                    width = im.size.width
                    height = im.size.height
                }
            }
            item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (string_url, error) in
                DispatchQueue.main.async {
                    if let url = string_url as? URL {
                        placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                            let iu = Image_url(url: url, width: Double(width), height: Double(height))
                            self.images.arr.insert(iu, at: insertionIndexPath.item)
                            Image_galleries.save(id: self.id, gallery: self.images)
                        })
                    } else {
                        placeholderContext.deletePlaceholder()
                    }
                }
            }
        }
    }
    
    private func remove_image(url: URL) {
        for i in 0..<images.arr.count {
            if images.arr[i].url == url { images.arr.remove(at: i); break; }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier, identifier == "showAbout" {
            if let destination = segue.destination as? AboutViewController {
                destination.name_temp = "Name: " + im_galleries.get_name(id)
                destination.number_temp = "Number: \(images.arr.count)"
                if let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(id).json") {
                    print(url.path)
                    if let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) {
                        print("lol")
                        if let created = attributes[.creationDate] as? Date {
                            destination.creation_temp = "Created: " + shortDateFormatter.string(from: created)
                        }
                        if let modified = attributes[.modificationDate] as? Date {
                            destination.modified_temp = "Modified: " + shortDateFormatter.string(from: modified)
                        }
                    }
                }
            }
        }
    }
    
    private let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
