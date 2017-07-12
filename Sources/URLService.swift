//
//  URLService.swift
//  MyFirstBackend
//
//  Created by bslayter on 7/12/17.
//
//

import PerfectLib
import PerfectHTTP

struct URLService {
    static func requestHandler(_ request: HTTPRequest, response: HTTPResponse) {
        response.setHeader(.contentType, value: "application/json")
        
        var resp = [String:String]()
        
        // Always set the response body and complete
        defer {
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
            }
            response.completed()
        }
        
        guard var theURL = request.param(name: "url") else {
            Log.error(message: "URL missing from request")
            
            response.status = .badRequest
            resp["error"] = "Please supply a url."
            return
        }
        
        guard theURL.isURL() else {
            response.status = .badRequest
            resp["error"] = "That doesn't look like a URL. Try again."
            return
        }
        
        if !theURL.hasPrefix("http://") && !theURL.hasPrefix("https://") {
            theURL = "http://" + theURL
        }
        
        if let existingEntry = getEntry(forURL: theURL) {
            resp["shortURL"] = existingEntry.getShortURL()
        } else {
            let urlModel = URLEntry()
            urlModel.url = theURL
            let identifier = UUID().string
            urlModel.shortCode = String(identifier.characters.prefix(through: identifier.index(identifier.startIndex, offsetBy: 6)))
            do {
                try urlModel.save()
                resp["shortURL"] = urlModel.getShortURL()
            } catch {
                print(error)
                resp["error"] = String(describing: error)
            }
        }
    }
    
    static func getEntry(forURL url: String) -> URLEntry? {
        let urlModel = URLEntry()
        do {
            try urlModel.select(whereclause: "url = ?", params: [url], orderby: ["id"])
            if urlModel.rows().count > 0 {
                return urlModel.rows().first
            }
        } catch {
            print(error)
            return nil
        }
        
        return nil
    }
}
