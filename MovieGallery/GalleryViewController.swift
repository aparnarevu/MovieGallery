//
//  GalleryViewController.swift
//  MovieGallery
//
//  Created by Aparna Revu on 5/2/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import UIKit

class GalleryViewController: UITableViewController,UIGestureRecognizerDelegate {

    var galleryResults = [Movie]()
    var cache:NSCache<AnyObject, AnyObject>!
    var imageBaseURL:String! = ""
    var imageLogoSize:String! = ""
    var imagePosterSize:String! = ""

    @IBOutlet weak var searchBar:UISearchBar?
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(GalleryViewController.dismissKeyboard))
        return recognizer
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString:String = kImageConfigurationAPI + kAPIKey

        downloadDataFromMovieDB(searchBy: urlString, isMovieData: false)

        self.cache = NSCache()
        self.title = NSLocalizedString(kTitleKey, comment: "Title")
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    
    // MARK: - Utility Methods
    func dismissKeyboard() {
        searchBar?.resignFirstResponder()
    }

    func updateResponse(_ data: Data?, isMovieData:Bool)  {
        do {
            if let data = data, let response = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue:0)) as? [String: AnyObject] {
                if isMovieData {
                    updateSearchResults(data, response: response )
                }else {
                    updateImageConfigurationDetails(data: data, response: response)
                }
            } else {
                print("JSON Error")
            }
        } catch let error as NSError {
            print("Error parsing results: \(error.localizedDescription)")
        }
    }

    func updateImageConfigurationDetails(data: Data?, response: [String: AnyObject])  {
        // Get the image dictionary
        if let imageDict: [String: AnyObject] = response[kImagesKey] as? [String : AnyObject] {
            if  let baseUrlUrl = imageDict[kImageBaseURLKey] as? String, let logoSizeList = imageDict[kLogoSizeKey] as? [AnyObject], let posterSizeList = imageDict[kPosterSizeKey] as? [AnyObject] {
                // Parse the image details
                self.imageBaseURL = baseUrlUrl
                self.imageLogoSize = logoSizeList[1] as! String
                self.imagePosterSize = posterSizeList[4] as! String
                
            } else {
                print("Not a dictionary")
            }
        } else {
            print("Results key not found in dictionary")
        }
    }
    
    
    func updateSearchResults(_ data: Data?, response: [String: AnyObject]) {
        
        self.galleryResults.removeAll()
        // Get the results array
        if let array: AnyObject = response[kResultsKey] {
           // print("Result:: ",array)
            for trackDictonary in array as! [AnyObject] {
                if let trackDictonary = trackDictonary as? [String: AnyObject], let previewUrl = trackDictonary[kPosterPathKey] as? String {
                    // Parse the search result
                    let title = trackDictonary[kMovieTitleKey] as? String
                    let movieId = trackDictonary[kMovieIdKey] as? Int
                    let releaseDate = trackDictonary[kReleaseDateKey] as? String
                    let language = trackDictonary[kLanguageKey] as? String
                    let overview = trackDictonary[kMovieOverViewKey] as? String
                    //print("Overview:: ",overview)
                    let logoImageURL = self.imageBaseURL + self.imageLogoSize  + previewUrl
                    let posterImageURL = self.imageBaseURL + self.imagePosterSize + previewUrl

                    galleryResults.append(Movie(movieId: movieId!, title: title!, overview: overview!, language: language!, releaseDate: releaseDate!, posterPath: posterImageURL, logoImageURL: logoImageURL))

                } else {
                    print("Not a dictionary")
                }
            }
        } else {
            print("Results key not found in dictionary")
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    // MARK: - TableView Datasource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.galleryResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifierKey, for: indexPath) as! MovieTableViewCell
        
        let movie = galleryResults[indexPath.row]
        cell.titleLabel.text = movie.title
        cell.releaseDateLabel.text = "Release Date: " + movie.releaseDate!
        cell.previewView.layer.cornerRadius = 15.0
        cell.previewView.layer.borderColor = UIColor.red.cgColor
        cell.previewView.layer.borderWidth = 2.0
        cell.previewView.layer.masksToBounds = true
        cell.previewView.backgroundColor = UIColor.clear
        if (self.cache.object(forKey: movie.logoImageURL! as String as AnyObject) != nil){
            // Use cache
            cell.previewView.image = self.cache.object(forKey: movie.logoImageURL as AnyObject) as? UIImage
        }else{
            
            cell.previewView.downloadTheImageForURL(imageUrlStr: movie.logoImageURL!, completion: { (downloadedImage) in
                DispatchQueue.main.async{
                    cell.previewView.image = downloadedImage
                }
                self.cache.setObject(downloadedImage, forKey: movie.logoImageURL! as String as AnyObject)
            })
            
        }
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsViewController = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
        detailsViewController?.selectedMovie = galleryResults[indexPath.row]
        self.navigationController?.pushViewController(detailsViewController!, animated: true)
        
    }
    
}

// MARK: - UISearchBarDelegate

extension GalleryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        dismissKeyboard()
        
        if !searchBar.text!.isEmpty {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            let expectedCharSet = CharacterSet.urlQueryAllowed
            let searchTerm = searchBar.text!.addingPercentEncoding(withAllowedCharacters: expectedCharSet)!
            let urlString:String = kMovieGalleryAPI + kAPIKey + "&query=\(searchTerm)"
            downloadDataFromMovieDB(searchBy:urlString,isMovieData: true)
        }
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tapRecognizer)
    }
}



extension GalleryViewController
{
    func downloadDataFromMovieDB(searchBy:String, isMovieData:Bool)  {
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
        var dataTask: URLSessionDataTask?
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // 4
        let url = URL(string: searchBy)
        // 5
        dataTask = defaultSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            // 6
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            // 7
            if let error = error {
                print(error.localizedDescription)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    self.updateResponse(data, isMovieData: isMovieData)
                }
            }
        })
        // 8
        dataTask?.resume()
        
    }

}

