//
//  DetailsViewController.swift
//  MovieGallery
//
//  Created by Aparna Revu on 5/3/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit
@IBDesignable class TopAlignedLabel: UILabel {
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSFontAttributeName: font],
                                                                    context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}


class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView:UIImageView?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    var selectedMovie:Movie?
    
    @IBOutlet weak var releaseDateLabel: UILabel!

    @IBOutlet weak var overViewLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Details"
        
        self.titleLabel.text = self.selectedMovie?.title
        self.languageLabel.text = "Language: " + (self.selectedMovie?.language)!
        self.releaseDateLabel.text = "Release Date: " + (self.selectedMovie?.releaseDate)!
        self.overViewLabel.text = self.selectedMovie?.movieOverview
        self.overViewLabel.numberOfLines = 0
        self.overViewLabel.sizeToFit()
        
        self.imageView?.downloadTheImageForURL(imageUrlStr: (selectedMovie?.posterImageURL)!, completion: { (downloadedImage) in
            DispatchQueue.main.async{
                self.imageView?.image = downloadedImage
            }
            
        })


        // Do any additional setup after loading the view.
    }

    override func viewWillLayoutSubviews() {
        overViewLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
