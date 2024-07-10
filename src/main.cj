import server.*
from std import collection.*
from std import reflect.*
from encoding import json.stream.*

class A <: JsonSerializable {
    public func toJson(w: JsonWriter): Unit {
        w.startObject()
        w.writeName("height").writeValue("100")
        w.writeName("width").writeValue("200")
        w.writeName("arr").writeValue(Array<Int64>([1, 2, 3]))
        w.writeName("list").writeValue(ArrayList<Int64>([1, 2, 3]))
        let m = HashMap<String, Int64>()
        m.put("1", 1)
        m.put("2", 2)
        w.writeName("map").writeValue(m)
        w.endObject()
    }
}

main(): Int64 {

    let engine = server.getDefaultEngine()
    let h: HandlerFunc = {
        ctx =>
        println("this is in handler")
        let m = HashMap<String, JsonSerializable>()
        m.put("1", 1)
        m.put("2", 2)
        m.put("name", ctx.getPathParam("name"))
        ctx.json(200, m)
        //ctx.json(200, A())
        //ctx.json(200, Array<Int64>([1, 2, 3, 4]))
    }

    let m1: MiddlewareFunc = {
        next => {
            ctx =>
            println("m1: this is before the handler")
            println(ctx.getPathParam("name"))
            println(ctx.getQuery("q"))
            println(ctx.getQuery("b"))
            next(ctx)
            println("m1: this is after the handler")
        }
    }
    let m2: MiddlewareFunc = {
        next => {
            ctx =>
            println("m2: this is before the handler")
            next(ctx)
            println("m2: this is after the handler")
        }
    }
    engine.mount("/p/hello", Router())
    engine.mount("/p/hello/:name/list", "GET", h, m1, m2)
    engine.run()

    return 0
}
