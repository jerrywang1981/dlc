package server

from std import collection.{reduce, ArrayList}

public class Config {
    public var caseSensitive: Bool = false
    public var noRouterConflict: Bool = true
    public let preMiddlewares: ArrayList<MiddlewareFunc> = ArrayList<MiddlewareFunc>()
    public let postMiddlewares: ArrayList<MiddlewareFunc> = ArrayList<MiddlewareFunc>()
    public var cache: ICache = HandlerCache()

    init() {
    }

    public prop preMiddleware: MiddlewareFunc {
        get() {
            reduce({a => a}, {a, b => a ~> b})(this.preMiddlewares)
        }
    }

    public prop postMiddleware: MiddlewareFunc {
        get() {
            reduce({a => a}, {a, b => a ~> b})(this.postMiddlewares)
        }
    }
}

public var config = getDefaultConfig()

public func setConfig(c: Config) {
    config = c
}

func getDefaultConfig() {
    let c = Config()
    c.preMiddlewares.append(paramMiddleware)
    c
}
