import { Hono } from "hono"
import { logger } from "hono/logger"
import { serve } from "@hono/node-server"
import { createNodeWebSocket } from "@hono/node-ws"
import { exec, execFile } from "node:child_process"

const app = new Hono()
app.use(logger())
const ws = createNodeWebSocket({ app })

const PROXY_DEST = "mstdn.rinsuki.net"
const PROXY_USER = "4553" // @imast_ios

app.post("/api/internal/set_status_bar", async c => {
    await new Promise((resolve, reject) => {
        const tz = -new Date("2007-01-09T09:41:00.000+01:00").getTimezoneOffset()
        execFile("xcrun", [
            "simctl", "--set", "testing",
            "status_bar", "booted", "override",
            "--time", [
                "2007-01-09T09:41:00.000",
                tz > 0 ? "+" : "-",
                Math.floor(Math.abs(tz) / 60).toString().padStart(2, "0"),
                ":",
                String(Math.abs(tz) % 60).padStart(2, "0")
            ].join(""),
            "--dataNetwork", "wifi",
            "--wifiMode", "active",
            "--wifiBars", "3",
            "--cellularMode", "active",
            "--cellularBars", "4",
            "--batteryState", "discharging",
            "--batteryLevel", "100",
        ], (err) => {
            if (err) {
                reject(err)
            } else {
                resolve(null)
            }
        })
    })
    return c.json({ success: true })
})

app.post("/api/v1/apps", async c => {
    return c.json({
        client_id: "__MOCK_CLIENT_ID__",
        client_secret: "secret",

        id: 0xDEADBEEF.toString(),
        name: "iMast (mock)",
        website: "https://cinderella-project.github.io/iMast/",
        redirect_uri: "imast://callback",
    })
})

app.get("/oauth/authorize", async c => {
    const url = new URL(c.req.query("redirect_uri")!)
    url.searchParams.set("code", "123456789abcdef")
    url.searchParams.set("state", c.req.query("state")!)
    return c.html(`<script async>setTimeout(() => window.location.href = ${JSON.stringify(url.toString())}, 1000)</script>`)
})

app.post("/oauth/token", async c => {
    return c.json({
        access_token: "__MOCK_ACCESS_TOKEN__",
        token_type: "Bearer",
        scope: "read write follow push",
        created_at: Math.floor(Date.now() / 1000),
    })
})

app.get("/api/v1/accounts/relationships", async c => {
    return c.json([{
        id: PROXY_USER,
        following: false,
        followed_by: false,
        blocking: false,
        blocked_by: false,
        muting: false,
        requested: false,
    }])
})

app.get("/api/v1/streaming/", ws.upgradeWebSocket(c => ({
    onOpen(e, ws) {
        setTimeout(() => {
            ws.close()
        }, 1000 * 1000)
    }
})))

const REDIR_MAP = {
    "/api/v1/accounts/verify_credentials": `/api/v1/accounts/${PROXY_USER}`,
    "/api/v1/timelines/home": `/api/v1/accounts/${PROXY_USER}/statuses`,
} as Record<string, string | undefined>

app.get("/*", async (c) => {
    const path = REDIR_MAP[c.req.path] ?? c.req.path
    const res = await fetch(`https://${PROXY_DEST}${path}${new URL(c.req.url).search}`, {
        method: c.req.method,
        headers: {
            "From": "imast-mock-server@rinsuki.net",
            "User-Agent": "imast_mock_server/0.1 (" + c.req.header("User-Agent") + ")",
        }
    })
    return new Response((await res.text()).replaceAll(`s://${PROXY_DEST}`, `://localhost:3000`), {
        status: res.status,
        headers: Array.from(res.headers.entries(), m => {
            return [
                m[0],
                m[1].replaceAll(`https://${PROXY_DEST}`, `http://localhost:3000`)
            ] as [string, string]
        }).filter(m => m[0].toLowerCase() !== "content-length")
    })
})

const server = serve({
    fetch: app.fetch,
    port: 3000,
}, info => {
    console.log(`Running at http://localhost:${info.port}`)
})
ws.injectWebSocket(server)