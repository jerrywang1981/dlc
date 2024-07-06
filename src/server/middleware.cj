package server

func paramMiddleware(next: HandlerFunc): HandlerFunc {
    {
        ctx =>
        if (let Some(v) <- ctx.data.get("ROUTER_RESULT")) {
            match (v) {
                case d: ArrayList<RouterSearchResult> =>
                    let m = HashMap<String, String>()
                    for (i in d where i.key.no_p_S.isParam) {
                        m.put(i.key.no_p_S.no_p_C, i.path.no_p_S)
                    }
                    ctx.param.set(m)
                case _ => ()
            }
        }
        next(ctx)
    }
}

func queryMiddleware(next: HandlerFunc): HandlerFunc {
    {
        ctx =>
        if (let Some(q) <- ctx.request.url.query) {
            let arr = q.split("&", removeEmpty: true)
            let m = HashMap<String, String>()
            for (p in arr) {
                let b = p.split("=", removeEmpty: true)
                if (b.size > 1) {
                    m.put(b[0], String.join(b[1..], delimiter: "="))
                }
            }
            ctx.query.set(m)
        }

        next(ctx)
    }
}
