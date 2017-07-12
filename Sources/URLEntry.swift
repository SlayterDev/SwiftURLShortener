//
//  File.swift
//  MyFirstBackend
//
//  Created by bslayter on 7/12/17.
//
//

import StORM
import MySQLStORM

class URLEntry: MySQLStORM {
    var id: Int = 0
    var url: String = ""
    var shortCode: String = ""
    var hits: Int = 0
    
    override open func table() -> String { return "url_entries" }
    
    override func to(_ this: StORMRow) {
        id = this.data["id"] as? Int ?? 0
        url = this.data["url"] as? String ?? ""
        shortCode = this.data["shortCode"] as? String ?? ""
        hits = this.data["hits"] as? Int ?? 0
    }
    
    func rows() -> [URLEntry] {
        var rows = [URLEntry]()
        for i in 0..<self.results.rows.count {
            let row = URLEntry()
            row.to(self.results.rows[i])
            rows.append(row)
        }
        
        return rows
    }
    
    func getShortURL() -> String {
        return "http://127.0.0.1:8181/go/" + shortCode
    }
}
