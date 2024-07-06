package server

public class Pair <: ToString {
    private let data: Map<String, String> = HashMap<String, String>()

    private var b: Bool = false

    public Pair() {}

    public func set(map: Map<String, String>) {
        if (!b) {
            for ((k, v) in map) {
                data.put(k, v)
            }
        }
        b = true
    }

    public operator func [](key: String): String {
        if (let Some(v) <- this.data.get(key)) {
            v
        } else {
            ""
        }
    }

    public func toString(): String {
        ""
    }
}
