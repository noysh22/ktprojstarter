package io.proj.ktprojstarter

import io.javalin.Javalin
import io.javalin.http.Context
import org.slf4j.LoggerFactory

object Controller {
    fun get(ctx: Context) {
        ctx.result("Welcome")
    }

    fun post(ctx: Context) {
        ctx.json(ctx.body())
    }
}

class Server(val port: Int) {

    private val app = Javalin.create()
        .apply { configureRoutes(this) }

    private fun configureRoutes(app: Javalin) {
        app.get("/", Controller::get)
        app.post("/echo", Controller::post)
    }

    fun start() {
        app.start(port)
        log.info("Started server on port $port")
    }

    fun stop() {
        app.stop()
        log.info("Stopped http server")
    }

    companion object {
        private val log = LoggerFactory.getLogger(Server::class.java)
    }
}

fun main() {

    val port = System.getenv("PORT")?.toInt() ?: 7070

    val server = Server(port)

    Runtime.getRuntime().addShutdownHook(
        Thread {
            println("Shutting down")
            server.stop()
        }
    )
    server.start()

}
