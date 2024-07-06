package server

from net import http.{HttpRequestDistributor, FuncHandler, HttpRequestHandler}

public class HttpRequestDistributor <: http.HttpRequestDistributor & ToString {
    private var handler: HttpRequestHandler

    HttpRequestDistributor() {
        this.handler = FuncHandler {ctx =>}
    }

    public func register(path: String, handler: HttpRequestHandler): Unit {
        logger.info("[class HttpRequestDistributor][register] path: ${path}")
        this.handler = handler
    }

    public func distribute(path: String): HttpRequestHandler {
        logger.info("[class HttpRequestDistributor][distribute] path: ${path}")
        return this.handler;
    }

    public func toString(): String {
        ""
    }
}
