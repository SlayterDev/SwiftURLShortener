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
        id = Int(this.data["id"] as? Int32 ?? 0)
        url = this.data["url"] as? String ?? ""
        shortCode = this.data["shortCode"] as? String ?? ""
        hits = Int(this.data["hits"] as? Int32 ?? 0)
    }
    
    func rows() -> [URLEntry] {
        var rows = [URLEntry]()
        for rowResult in self.results.rows {
            let row = URLEntry()
            row.to(rowResult)
            rows.append(row)
        }
        
        return rows
    }
    
    func getShortURL() -> String {
        return "http://127.0.0.1:8181/go/" + shortCode
    }
}
