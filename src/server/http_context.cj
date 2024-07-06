package server

from net import http.{HttpResponseBuilder, HttpRequest}
from crypto import x509.X509Certificate

public class HttpContext <: ToString {
    // the map to hold any data you want to have in handler chain
    public let data = DMap()
    private let _param = Pair()
    private let _query = Pair()

    HttpContext(public let context: http.HttpContext) {
    }

    public prop responseBuilder: HttpResponseBuilder {
        get() {
            this.context.responseBuilder
        }
    }

    public prop clientCertificate: ?Array<X509Certificate> {
        get() {
            this.context.clientCertificate
        }
    }

    public prop request: HttpRequest {
        get() {
            this.context.request
        }
    }

    public prop param: Pair {
        get() {
            this._param
        }
    }

    public prop query: Pair {
        get() {
            this._query
        }
    }

    public func html(status: UInt16, content: String): HttpResponseBuilder {
        this.context.responseBuilder.header("content-type", "text/html; charset=utf-8").status(status).body(content)
    }

    public func string(status: UInt16, content: String): HttpResponseBuilder {
        this.context.responseBuilder.status(status).body(content)
    }

    public func toString(): String {
        ""
    }
}
