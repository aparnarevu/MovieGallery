//
//  MovieTableViewCell.swift
//  MovieGallery
//
//  Created by Aparna Revu on 5/2/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadTheImageForURL(imageUrlStr:String, completion: @escaping ((_ image: UIImage) -> Void)) {
        // the data was received and parsed to String
        let thumbImageURL = URL(string: imageUrlStr)!
        //print("thumbImageURL:: ",thumbImageURL)
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: thumbImageURL) { (data, response, error) in
            // The download has finished.
            if let e = error {
                print("Error downloading image: \(e)")
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if (response as? HTTPURLResponse) != nil {
                    //print("Downloaded image with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let downloadedImage = UIImage(data: imageData)
                        completion(downloadedImage!)
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
        }
        
        downloadPicTask.resume()
    }

}


class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var previewView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.previewView.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
