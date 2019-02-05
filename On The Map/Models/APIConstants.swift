//
//  APIConstants.swift
//  On The Map
//
//  Created by Norah Al Ibrahim on 1/30/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct URLBase {
    
    static let udacity = "https://onthemap-api.udacity.com/v1/"
    static let parse = "https://parse.udacity.com/parse/classes/"
}

struct UdacityPath {
    
    static let session = "session"
    static let users = "users"
    
}

struct ParsePath {
    
    static let studentLocation = "StudentLocation"
    
}


struct Parse {
    
    static let appId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
    static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    
}

struct Default {
    static let timeout = 10
}

struct APIError {
    
    static let invalidRequestBodyCode = 10000
    
    struct Messages {
        
        static let timedOut = "Error trying to connect. Please check your connection and try again."
        static let unknownError = "An unknown error has occured!"
        static let invalidCredentials = "Invalid username and/or password!"
        static let invalidRequestBody = "Invalid Request Body!"
        static let cookieNotFound = "Could not find the session cookie!"
        static let serializationFailure = "Couldn't serialize the object"
    }
    
}
