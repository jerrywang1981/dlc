package server

from std import collection.HashMap

public class DMap {
    private let data: Map<String, Any> = HashMap<String, Any>()
    init() {}

    public func put(key: String, value: Any): Option<Any> {
        this.data.put(key, value)
    }

    public func get(key: String): Option<Any> {
        this.data.get(key)
    }
}
