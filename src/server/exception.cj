package server

class RouterConflictException <: Exception & ToString {
    RouterConflictException(private let path: String) {}

    public func toString(): String {
        "Duplicate router: ${path}"
    }

    public prop pathName: String {
        get() {
            this.path
        }
    }
}
