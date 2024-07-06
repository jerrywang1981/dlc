package server

from std import collection.HashMap
from std import log.*
from std import console.*

let logger: SimpleLogger = SimpleLogger("[DLC WEB Server]", LogLevel.ALL, Console.stdOut)

public type HandlerFunc = (HttpContext) -> Unit

public type MiddlewareFunc = (HandlerFunc) -> HandlerFunc

const SLASH = "/"
const STAR = "*"
const COLON = ":"

extend String {
    public prop hasTrailingSlash: Bool {
        get() {
            this.endsWith(SLASH)
        }
    }

    public func toArr(): Array<String> {
        this.split(SLASH, removeEmpty: true)
    }

    public prop isStar: Bool {
        get() {
            this == STAR
        }
    }

    public prop isSlash: Bool {
        get() {
            this == SLASH
        }
    }

    public func trim(): String {
        this.trimAscii().replace(" ", "")
    }

    public prop isParam: Bool {
        get() {
            this.startsWith(COLON)
        }
    }

    public prop p_S: String {
        get() {
            if (this.startsWith(SLASH)) {
                this
            } else {
                SLASH + this
            }
        }
    }

    public prop no_p_S: String {
        get() {
            if (this.startsWith(SLASH)) {
                this[1..]
            } else {
                this
            }
        }
    }

    public prop no_p_C: String {
        get() {
            if (this.startsWith(COLON)) {
                this[1..]
            } else {
                this
            }
        }
    }
}

public struct RouterSearchResult {
    /*
    path: /jerry , part of the url path
    key: /jerry or /:id , the key in router map
    isLeaf: whether this result is for the leaf or not
    router: the router object
     */
    RouterSearchResult(let path: String, let key: String, let isLeaf: Bool, let router: Router) {}
}

public interface IMountable<T> {
    func mount(path: String, method: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func get(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func head(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func options(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func post(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func put(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func patch(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func delete(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): T
    func mount(path: String, router: Router): T
}
