package server

from std import collection.HashMap

public interface ICache {
    func get(key: String): ?HandlerFunc
    func put(key: String, handler: HandlerFunc): Unit
    func destroy(): Unit
}

public class HandlerCache <: ICache {
    private let map: Map<String, HandlerFunc> = HashMap<String, HandlerFunc>()

    init() {}

    private func compareStr(s1: String, s2: String, exact!: Bool = true): Bool {
        if (s1.hasTrailingSlash && !s2.hasTrailingSlash) {
            return false
        }
        if (s2.hasTrailingSlash && !s1.hasTrailingSlash) {
            return false
        }

        let a1 = s1.toArr()
        let a2 = s2.toArr()
        if (a1.size != a2.size) {
            return false
        }

        if (exact) {
            for (i in 0..a1.size) {
                if (a1[i] != a2[i]) {
                    return false
                }
            }
            return true
        } else {
            for (i in 0..a1.size) {
                if (a1[i] != a2[i] && !a1[i].isParam && !a2[i].isParam) {
                    return false
                }
            }
            return true
        }
    }

    public func get(key: String): ?HandlerFunc {
        // exact match
        for ((k, v) in this.map) {
            if (this.compareStr(k, key)) {
                return Some(v)
            }
        }
        // fuzzy search

        for ((k, v) in this.map) {
            if (this.compareStr(k, key, exact: false)) {
                return Some(v)
            }
        }
        None
    }

    public func put(key: String, handler: HandlerFunc): Unit {
        this.map.put(key, handler)
    }

    public func destroy(): Unit {
        this.map.clear()
    }
}
