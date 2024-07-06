import server.*
from std import collection.*

type M = (String) -> Unit

type P = (M) -> M

let t1: P = {
    next => {
        ctx =>
        println("in t1")
        next(ctx)
    }
}
let t2: P = {
    next => {
        ctx =>
        println("in t2")
        next(ctx)
    }
}
let t3: P = {
    next => {
        ctx =>
        println("in t3")
        next(ctx)
    }
}
let t4: P = {
    next => {
        ctx =>
        println("in t4")
        next(ctx)
    }
}
let r1 = t4 ~> t3 ~> t2 ~> t1
let r20 = reduce({a: M => a}, {a, b => a ~> b})(ArrayList<P>([t1, t2]))
let r21 = reduce({a: M => a}, {a, b => a ~> b})(ArrayList<P>([t3, t4]))
let r2 = r21 ~> r20
let i1: M = {m1: String => println("in handler")}

main(): Int64 {
    let c: (name: String, age: Int64) = ("banana", 5)
    //    "" |> r1(i1)
    //   println("-------------------")
    //  "" |> r2(i1)
    //println(r2(i1))

    /*
    let engine = Engine("127.0.0.1", 8888)
    let h: HandlerFunc = {
        ctx =>
        println("this is in handler")
        ctx.responseBuilder.body("ok")
    }

    let m1: MiddlewareFunc = {
        next => {
            ctx =>
            println("m1: this is before the handler")
            println(ctx.param["name"])
            println(ctx.query["q"])
            println(ctx.query["b"])
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
    engine.mount("/p/hello/:name", "GET", h, m1, m2, m3)
    engine.run()
     */
    return 0
}
