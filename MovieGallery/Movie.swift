//
//  Movie.swift
//  MovieGallery
//
//  Created by Aparna Revu on 5/2/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import Foundation

struct Movie {
    var title:String?
    var movieOverview:String?
    var id:Int?
    var language:String?
    var releaseDate:String?
    var posterImageURL:String?
    var logoImageURL:String?


    init(movieId:Int, title:String, overview:String, language:String, releaseDate:String, posterPath:String,logoImageURL:String ) {
        self.id = movieId
        self.title = title
        self.movieOverview = overview
        self.language = language
        self.releaseDate = releaseDate
        self.posterImageURL = posterPath
        self.logoImageURL = logoImageURL

    }
    
}
