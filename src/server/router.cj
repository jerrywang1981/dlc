package server

from std import collection.{Map, HashMap, ArrayList}

public class Router <: ToString & IMountable<Router> {
    // normal routers
    private let routers: Map<String, Map<String, HandlerFunc>>
    // router groups
    private let routerGroups: Map<String, Router>

    // router level middleware
    private let middlewares: ArrayList<MiddlewareFunc>
    // router method level middleware
    private let methodMiddlewares: Map<String, Map<String, ArrayList<MiddlewareFunc>>>

    public Router() {
        this.routers = HashMap<String, Map<String, HandlerFunc>>()
        this.routerGroups = HashMap<String, Router>()
        this.middlewares = ArrayList<MiddlewareFunc>()
        this.methodMiddlewares = HashMap<String, Map<String, ArrayList<MiddlewareFunc>>>()
    }

    private func normPath(path: String): String {
        if (config.caseSensitive) {
            path
        } else {
            path.toAsciiLower()
        }
    }

    private func validatePath(path: String): Bool {
        !path.contains(STAR) && !path.contains(COLON)
    }

    private func p_mount(path: String, method: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        let key = if (path.isSlash) {
            path
        } else {
            SLASH + this.normPath(path)
        }
        // handler
        match (this.routers.get(key)) {
            case Some(v) => match (v.get(method)) {
                case Some(w) => if (config.noRouterConflict) {
                    throw RouterConflictException(path)
                } else {
                    v.put(method, handler)
                }
                case None => v.put(method, handler)
            }
            case None =>
                this.routers.put(key, HashMap<String, HandlerFunc>())
                this.routers[key].put(method, handler)
        }

        // middlewares
        match (this.methodMiddlewares.get(key)) {
            case Some(v) => match (v.get(method)) {
                case Some(w) => w.appendAll(middlewares)
                case None => v.put(method, ArrayList<MiddlewareFunc>(middlewares))
            }
            case None =>
                this.methodMiddlewares.put(key, HashMap<String, ArrayList<MiddlewareFunc>>())
                this.methodMiddlewares[key].put(method, ArrayList<MiddlewareFunc>(middlewares))
        }

        return this
    }

    /**
     * mount the router method handler
     *
     * @param path String the mount path, e.g. /hello/jerry, /product/:id, /product/:id/list
     * @param method String the request method, GET/POST/PUT/DELETE/PATCH/OPTIONS
     * @param handler HandlerFunc the handler function to process/handle the request
     * @param middlewares Array<MiddlewareFunc> the middlewares of this path/endpoint
     *
     * @return this router
     */
    public func mount(path: String, method: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        let p = this.normPath(path.trim())
        // if p is "/"
        if (p.isSlash) {
            p_mount(p, method, handler, middlewares)
            return this
        }

        let pArr = p.toArr()
        if (pArr.size == 1) {
            if (p.hasTrailingSlash) {
                match (this.routerGroups.get(pArr[0])) {
                    case Some(v) => v.mount(SLASH, method, handler, middlewares)
                    case None =>
                        let r = Router()
                        r.mount(SLASH, method, handler, middlewares)
                        this.routerGroups.put(SLASH + pArr[0], r)
                }
            } else {
                p_mount(pArr[0], method, handler, middlewares)
            }
            return this
        }

        match (this.routerGroups.get(pArr[0])) {
            case None =>
                let r = Router()
                this.routerGroups.put(SLASH + pArr[0], r)
            case _ => ()
        }

        let nPath = if (p.hasTrailingSlash) {
            String.join(pArr[1..], delimiter: SLASH) + SLASH
        } else {
            String.join(pArr[1..], delimiter: SLASH)
        }

        this.routerGroups[SLASH + pArr[0]].mount(nPath, method, handler, middlewares)

        return this
    }

    public func get(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "GET", handler, middlewares)
    }
    public func head(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "HEAD", handler, middlewares)
    }
    public func options(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "OPTIONS", handler, middlewares)
    }
    public func post(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "POST", handler, middlewares)
    }
    public func put(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "PUT", handler, middlewares)
    }
    public func patch(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "PATCH", handler, middlewares)
    }
    public func delete(path: String, handler: HandlerFunc, middlewares: Array<MiddlewareFunc>): This {
        this.mount(path, "DELETE", handler, middlewares)
    }

    public func mount(path: String, router: Router): This {
        let p = this.normPath(path.trim())
        let pArr = p.toArr()

        if (pArr.size == 0) {
            throw RouterConflictException(path)
        }

        if (pArr.size == 1) {
            let k = pArr[0].p_S
            if (this.routerGroups.contains(k)) {
                if (config.noRouterConflict) {
                    throw RouterConflictException(path)
                } else {
                    this.routerGroups.put(k, router)
                }
            } else {
                this.routerGroups.put(k, router)
            }
            return this
        }

        var root = this
        for (i in 0..pArr.size) {
            let k = pArr[i].p_S
            // last one
            if (i == pArr.size - 1) {
                root.mount(k, router)
                break
            }
            if (!root.hasRouterGroupPath(k)) {
                root.mount(k, Router())
            }
            root = root.getRouterGroup(k).getOrThrow()
        }

        return this
    }

    private func p_getHandlers(path: String, isLeaf!: Bool = false): ArrayList<RouterSearchResult> {
        let result = ArrayList<RouterSearchResult>()
        if (isLeaf) {
            match (this.routers.get(SLASH + path)) {
                case Some(v) => result.append(RouterSearchResult(SLASH + path, SLASH + path, true, this))
                case None => for ((k, _) in this.routers where !k.isEmpty()) {
                    if (k[1..].isParam || k[1..].isStar) {
                        result.append(RouterSearchResult(SLASH + path, k, true, this))
                    }
                }
            }
        } else {
            match (this.routerGroups.get(SLASH + path)) {
                case Some(v) => result.append(RouterSearchResult(SLASH + path, SLASH + path, false, v))
                case None => for ((k, v) in this.routerGroups where !k.isEmpty()) {
                    if (k[1..].isParam || k[1..].isStar) {
                        result.append(RouterSearchResult(SLASH + path, k, false, v))
                    }
                }
            }
        }
        result
    }

    // (realpath: String, key in router: String, is leaf: Bool, ?Router)
    public func getHandlers(fullPath: String): ArrayList<RouterSearchResult> {
        let result = ArrayList<RouterSearchResult>()
        let path = this.normPath(fullPath)
        if (!this.validatePath(path)) {
            logger.warn("[class Router][getHandlers] invalid path: ${fullPath}")
            return result
        }

        if (path.isSlash || path.isEmpty()) {
            if (this.routers.contains(SLASH)) {
                result.append(RouterSearchResult(SLASH, SLASH, true, this))
            }
            return result
        }

        let pArr = path.toArr()
        if (pArr.size == 1) {
            let a = if (path.hasTrailingSlash) {
                p_getHandlers(pArr[0])
            } else {
                p_getHandlers(pArr[0], isLeaf: true)
            }
            if (a.size > 0) {
                result.append(a[0])
            }
            return result
        }

        let key = pArr[0]
        let remainingPath = String.join(pArr[1..], delimiter: SLASH) + if (path.hasTrailingSlash) {
            SLASH
        } else {
            ""
        }

        let a = p_getHandlers(key)
        if (a.size == 0) {
            return result
        }
        // loop
        for (i in a) {
            let b = i.router.getHandlers(remainingPath)
            if (b.size == 0) {
                continue
            }
            if (b[b.size - 1].isLeaf) {
                result.append(i)
                result.appendAll(b)
                break
            }
        }

        if (path.hasTrailingSlash && (path + "INDEX").split(SLASH, removeEmpty: true).size == result.size) {
            return result
        }
        if (path.split(SLASH, removeEmpty: true).size == result.size) {
            return result
        }

        ArrayList<RouterSearchResult>()
    }

    public func getHandlers(fullPath: String, method: String): (?ArrayList<RouterSearchResult>, ?HandlerFunc) {
        let result = this.getHandlers(fullPath)
        if (result.size == 0) {
            return (None, None)
        }
        let last = result[result.size - 1]
        if (!last.isLeaf) {
            return (None, None)
        }
        match (last.router.getPathHandler(last.key, method)) {
            case Some(v) => (result, v)
            case None => (result, None)
        }
    }

    // the key and method must be valid
    protected func getPathHandler(key: String, method: String): ?HandlerFunc {
        match (this.routers.get(key)) {
            case Some(v) => return v.get(method)
            case None => return None
        }
    }

    // path is the key in the map, not the actual url path
    public func getMiddlewares(path: String, isLeaf!: Bool = false, method!: String = "GET"): ArrayList<MiddlewareFunc> {
        let mw = ArrayList<MiddlewareFunc>()

        mw.appendAll(this.middlewares)
        if (isLeaf) {
            match (this.methodMiddlewares.get(path)) {
                case Some(v) => match (v.get(method)) {
                    case Some(w) => mw.appendAll(w)
                    case None => ()
                }
                case None => ()
            }
        }
        mw
    }

    /*
    func hasRouterPath(path: String): Bool {
        this.routers.contains(path.p_S)
    }
     */
    func hasRouterGroupPath(path: String): Bool {
        this.routerGroups.contains(path.p_S)
    }

    /**
     * get the router group by path
     * @param path String e.g. /hello/jerry
     * @return Option<Router> the router
     *
     */
    public func getRouterGroup(path: String): ?Router {
        let p = this.normPath(path.trim())
        let pArr = p.toArr()
        if (pArr.size == 0) {
            return Some(this)
        }
        if (pArr.size == 1) {
            return this.routerGroups.get(pArr[0].p_S)
        }
        let k = pArr[0].p_S
        let newPath = String.join(pArr[1..], delimiter: SLASH)
        match (this.routerGroups.get(k)) {
            case Some(v) => return v.getRouterGroup(newPath)
            case None => return None
        }
    }

    public func staticFileHandler(relativePath: String, handler: HandlerFunc): This {
      if (relativePath.contains(COLON) || relativePath.contains(STAR)) {
        throw Exception("URL cannot contain colon or star when serving static files")
      }

      this.get(relativePath, handler)
      this.head(relativePath, handler)
      this
    }

    public func toString(): String {
        let sb = StringBuilder("*******************Router(start)*******************\n")
        sb.append("Router keys: \n")
        sb.append(this.routers.keys().toArray().toString() + "\n")
        sb.append("Router Group keys: \n")
        sb.append(this.routerGroups.keys().toArray().toString() + "\n")
        sb.append("Middleware keys: \n")
        sb.append(this.methodMiddlewares.keys().toArray().toString() + "\n")
        sb.append("*******************Router(end)*******************\n")
        sb.toString()
    }
}
