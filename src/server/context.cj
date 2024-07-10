package server

from net import http.{HttpResponseBuilder, HttpRequest}
from std import io.ByteArrayStream, collection.ArrayList
from crypto import x509.X509Certificate
from encoding import json.stream.*, url.*

public class HttpContext <: ToString {
    // the map to hold any data you want to have in handler chain
    public let data = DMap()
    protected let _param: url.Form = url.Form()
    private let _query:url.Form

    HttpContext(public let context: http.HttpContext) {
      this._query = context.request.url.queryForm
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

    /*
    public prop param: Pair {
        get() {
            this._param
        }
    }

    public prop query: url.Form {
        get() {
            this._query
        }
    }
    */

    public func getPathParam(key: String): String {
      this._param.get(key).getOrDefault({=>""})
    }

    public func getPathParamDefault(key: String, defaultValue: String): String {
      this._param.get(key).getOrDefault({=>defaultValue})
    }

    public func getQuery(key: String): String {
      this._query.get(key).getOrDefault({=>""})
    }

    public func getQueryDefault(key: String, defaultValue: String): String {
      this._query.get(key).getOrDefault({=>defaultValue})
    }

    public func getQueryAll(key: String): ArrayList<String> {
      this._query.getAll(key)
    }

    public func html(status: UInt16, content: String): HttpResponseBuilder {
        this.context.responseBuilder.header("content-type", "text/html; charset=utf-8").status(status).body(content)
    }

    public func string(status: UInt16, content: String): HttpResponseBuilder {
        this.context.responseBuilder.status(status).body(content)
    }

    public func json<T>(status: UInt16, data: T): HttpResponseBuilder where T <: JsonSerializable {
        let stream = ByteArrayStream()
        let writer = JsonWriter(stream)
        writer.writeValue(data)
        writer.flush()
        this.context.responseBuilder.status(status).header("Content-Type", "application/json; charset=utf-8").body(
            stream)
    }

    public func toString(): String {
        ""
    }
}
