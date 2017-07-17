//
//  URLService.swift
//  MyFirstBackend
//
//  Created by bslayter on 7/12/17.
//
//

import PerfectLib
import PerfectHTTP
import PerfectMustache

struct URLService {
    static func requestHandler(_ request: HTTPRequest, response: HTTPResponse) {
        var resp = [String:String]()
        
        // Redirect to '/' to reload home
        defer {
            response.setHeader(.contentType, value: "application/json")
            do {
                try response.setBody(json: resp)
            } catch {
                print(error)
                response.status = .internalServerError
            }
            response.completed()
        }
        
        guard var theURL = request.param(name: "url") else {
            Log.error(message: "URL missing from request")
            
            response.status = .badRequest
            resp["error"] = "Please supply a url."
            return
        }
        
        if let errorString = checkURL(&theURL) {
            response.status = .badRequest
            resp["error"] = errorString
            return
        }
        
        let (shortURL, error) = saveURL(theURL)
        if let shortURL = shortURL {
            resp["shortURL"] = shortURL
        } else if let error = error {
            response.status = .internalServerError
            resp["error"] = String(describing: error)
        } else {
            response.status = .internalServerError
            resp["error"] = "Could not create short url at this time"
        }
    }
    
    static func saveURL(_ theURL: String) -> (String?, Error?) {
        if let existingEntry = getEntry(forURL: theURL) {
            return (existingEntry.getShortURL(), nil)
        } else {
            let urlModel = URLEntry()
            urlModel.url = theURL
            let identifier = UUID().string
            urlModel.shortCode = String(identifier.characters.prefix(through: identifier.index(identifier.startIndex, offsetBy: 6)))
            do {
                try urlModel.save()
                return (urlModel.getShortURL(), nil)
            } catch {
                print(error)
                return (nil, error)
            }
        }
    }
    
    static func checkURL(_ theURL: inout String) -> String? {
        guard theURL.isURL() else {
            return "That doesn't look like a URL. Try again."
        }
        
        if !theURL.hasPrefix("http://") && !theURL.hasPrefix("https://") {
            theURL = "http://" + theURL
        }
        
        return nil
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

extension URLService: MustachePageHandler {
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
        if var theURL = contxt.webRequest.param(name: "url"), URLService.checkURL(&theURL) == nil {
            let _ = URLService.saveURL(theURL)
        }
        
        var values = MustacheEvaluationContext.MapType()
        let urlModel = URLEntry()
        do {
            try urlModel.findAll()
        } catch {
            print(error)
        }
        
        var arr = [Any]()
        for row in urlModel.rows() {
            var thisURL = [String:String]()
            thisURL["id"] = String(row.id)
            thisURL["url"] = row.url
            thisURL["shortURL"] = row.getShortURL()
            arr.append(thisURL)
        }
        
        values["urls"] = arr
        contxt.extendValues(with: values)
        
        do {
            try contxt.requestCompleted(withCollector: collector)
        } catch {
            let response = contxt.webResponse
            response.status = .internalServerError
            response.appendBody(string: "\(error)")
            response.completed()
        }
    }
}
