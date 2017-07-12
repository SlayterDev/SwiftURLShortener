//
//  RedirectService.swift
//  MyFirstBackend
//
//  Created by bslayter on 7/12/17.
//
//

import PerfectLib
import PerfectHTTP

struct RedirectService {
    static func requestHandler(_ request: HTTPRequest, response: HTTPResponse) {
        let shortCode = request.urlVariables["shortCode"] ?? ""
        
        var destination = "/"
        if !shortCode.isEmpty {
            let urlModel = URLEntry()
            do {
                try urlModel.select(whereclause: "shortCode = ?", params: [shortCode], orderby: ["id"])
            } catch {
                Log.error(message: String(describing: error))
            }
            
            if let result = urlModel.rows().first {
                destination = result.url
            }
        }
        
        Log.info(message: "Redirecting /go/\(shortCode) to \(destination)")
        
        response.setHeader(.contentType, value: "text/html")
        
        response.status = .found // 302 temp redirect
        
        response.setHeader(.location, value: destination)
        
        response.completed()
    }
}
