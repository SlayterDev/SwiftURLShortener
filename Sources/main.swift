import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

let server = HTTPServer()

var routes = Routes()
routes.add(method: .get, uri: "/", handler: { request, response in
	response.setHeader(.contentType, value: "text/html")
	response.appendBody(string: "<html><title>Hello, World</title><body>Hello, world!</body></html>")
	response.completed()
})

server.addRoutes(routes)

server.serverPort = 8181

do {
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
