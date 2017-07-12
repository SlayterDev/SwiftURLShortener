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
        response.setHeader(.contentType, value: "text/html")
        
        var resp = [String:String]()
        
        // Redirect to '/' to reload home
        defer {
            response.setHeader(.contentType, value: "text/html")
            response.status = .found // 302 temp redirect
            response.setHeader(.location, value: "/")
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

extension URLService: MustachePageHandler {
    func extendValuesForResponse(context contxt: MustacheWebEvaluationContext, collector: MustacheEvaluationOutputCollector) {
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
