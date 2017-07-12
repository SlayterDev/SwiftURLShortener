import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import StORM
import MySQLStORM

let server = HTTPServer()

MySQLConnector.host = "127.0.0.1"
MySQLConnector.username = "root"
MySQLConnector.password = ""
MySQLConnector.database = "testdb"
MySQLConnector.port = 3306

let obj = URLEntry()
try? obj.setup()

var routes = Routes()
routes.add(method: .get, uri: "/", handler: { request, response in
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, World</title><body>Hello, world!</body></html>")
	response.completed()
})
routes.add(method: .post, uri: "/use", handler: URLService.requestHandler(_:response:))
routes.add(method: .get, uri: "/go/{shortCode}", handler: RedirectService.requestHandler(_:response:))

server.addRoutes(routes)

server.serverPort = 8181

do {
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
