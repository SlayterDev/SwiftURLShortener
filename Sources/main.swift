import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PerfectMustache
import StORM
import MySQLStORM

let server = HTTPServer()

server.documentRoot = "./webroot"

MySQLConnector.host = "127.0.0.1"
MySQLConnector.username = "urluser"
MySQLConnector.password = ""
MySQLConnector.database = "testdb"
MySQLConnector.port = 3306

let obj = URLEntry()
try? obj.setup()

var routes = Routes()
routes.add(method: .get, uri: "/", handler: { request, response in
	response.setHeader(.contentType, value: "text/html")
	
    mustacheRequest(request: request, response: response, handler: URLService(), templatePath: request.documentRoot + "/index.mustache")
    
	response.completed()
})
routes.add(method: .post, uri: "/shorten", handler: URLService.requestHandler(_:response:))
routes.add(method: .get, uri: "/go/{shortCode}", handler: RedirectService.requestHandler(_:response:))

server.addRoutes(routes)

server.serverPort = 8181

do {
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
