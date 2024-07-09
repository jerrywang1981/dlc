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
                case t: (String, String) =>
                    let (p1, p2) = t
                    let (a1, a2) = (p1.toArr(), p2.toArr())
                    if (a1.size == a2.size || a1.size > 0) {
                        let m = HashMap<String, String>()
                        for (i in 0..a1.size) {
                            if (a1[i].isParam) {
                                m.put(a1[i].no_p_C, a2[i])
                            }
                        }
                        ctx.param.set(m)
                    }

                case _ => ()
            }
        }
        next(ctx)
    }
}

/*
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
*/
