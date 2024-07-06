package server

from net import http.{Server, ServerBuilder, HttpContext, HttpStatusCode}
from std import collection.{reduce, map, collectArray}

public class Engine <: IMountable<Engine> {
    private let server: Server
    private let router: Router

    public Engine(addr: String, port: UInt16) {
        this.router = Router()
        this.server = ServerBuilder().addr(addr).port(port).distributor(HttpRequestDistributor()).build()
    }

    public init(svr: Server) {
        this.router = Router()
        this.server = svr
    }

    public init(svrBuilder: ServerBuilder) {
        this.router = Router()
        this.server = svrBuilder.distributor(HttpRequestDistributor()).build()
    }

    public func run() {
        this.server.distributor.register("/", this.handler)
        this.server.serve()
    }

    public func mount(path: String, method: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.mount(path, method, handler, middlewares)
        this
    }

    public func mount(path: String, router: Router): This {
        this.router.mount(path, router)
        this
    }

    public func get(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.get(path, handler, middlewares)
        this
    }
    public func head(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.head(path, handler, middlewares)
        this
    }
    public func options(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.options(path, handler, middlewares)
        this
    }
    public func post(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.post(path, handler, middlewares)
        this
    }
    public func put(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.put(path, handler, middlewares)
        this
    }
    public func patch(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.patch(path, handler, middlewares)
        this
    }
    public func delete(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.router.delete(path, handler, middlewares)
        this
    }

    private func combineMiddlewares(chain: ArrayList<RouterSearchResult>, method: String): MiddlewareFunc {
        let middlewares = ArrayList<MiddlewareFunc>()
        for (i in chain) {
            middlewares.appendAll(i.router.getMiddlewares(i.key, isLeaf: i.isLeaf, method: method))
        }

        reduce({a => a}, {a, b => a ~> b})(middlewares)
    }

    private func getCacheKey(chain: ArrayList<RouterSearchResult>, method: String, hasTrailingSlash: Bool): String {
        var m = String.join(collectArray(map({c: RouterSearchResult => c.key.no_p_S})(chain)), delimiter: SLASH)
        if (hasTrailingSlash) {
            m = m + SLASH
        }
        method + m.p_S
    }

    func handler(ctx: http.HttpContext): Unit {
        let method = ctx.request.method
        let path = ctx.request.url.path

        // try to find in cache first
        if (let Some(v) <- config.cache.get(method + path)) {
            return v(HttpContext(ctx))
        }

        let (chain, cb) = this.router.getHandlers(path, method)

        /*
        match (cb) {
            case Some(v) => match (chain) {
                case Some(w) =>
                    let middleware = config.postMiddleware ~> this.combineMiddlewares(w, method) ~> config.preMiddleware
                    let newHandler = v |> middleware
                    // cache it
                    let ckey = this.getCacheKey(w, method, path.hasTrailingSlash)
                    config.cache.put(ckey, newHandler)
                    let context = HttpContext(ctx)
                    // save some data into the context
                    context.data.put("ROUTER_RESULT", w)
                    return newHandler(context)
                case None => println("path: ${path}, method: ${method} handler found, but something went wrong")
            }
            case None => println("path: ${path}, method: ${method} handler not found")
        }
         */
        if (let Some(v) <- cb) {
            if (let Some(w) <- chain) {
                let middleware = config.postMiddleware ~> this.combineMiddlewares(w, method) ~> config.preMiddleware
                let newHandler = v |> middleware
                // cache it
                let ckey = this.getCacheKey(w, method, path.hasTrailingSlash)
                config.cache.put(ckey, newHandler)
                let context = HttpContext(ctx)
                // save some data into the context
                context.data.put("ROUTER_RESULT", w)
                return newHandler(context)
            }
        }

        return FuncHandler({
            ctx => ctx.responseBuilder.status(HttpStatusCode.STATUS_NOT_FOUND)
        }).handle(ctx)
    }
}
