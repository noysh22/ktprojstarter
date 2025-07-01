package io.proj.ktprojstarter

import io.javalin.Javalin
import io.javalin.http.Context
import io.proj.ktprojstarter.echo.EchoServer
import kotlinx.coroutines.runBlocking
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

fun main() = runBlocking {
    val httpPort = System.getenv("PORT")?.toInt() ?: 7070
    val grpcPort = System.getenv("GRPC_PORT")?.toInt() ?: 9090
    
    val log = LoggerFactory.getLogger("Main")
    
    log.info("Starting application with HTTP port: $httpPort, gRPC port: $grpcPort")
    
    val httpServer = Server(httpPort)
    val grpcServer = EchoServer(grpcPort)
    
    // Setup shutdown hook for graceful shutdown
    Runtime.getRuntime().addShutdownHook(
        Thread {
            log.info("Shutting down servers...")
            httpServer.stop()
            grpcServer.stop()
            log.info("Servers shut down complete")
        }
    )
    
    // Start both servers
    try {
        grpcServer.start()
        httpServer.start()
        
        log.info("Both HTTP and gRPC servers started successfully")
        log.info("HTTP server available at: http://localhost:$httpPort")
        log.info("gRPC server available at: localhost:$grpcPort")
        
        // Block until shutdown
        grpcServer.blockUntilShutdown()
    } catch (e: Exception) {
        log.error("Error starting servers", e)
        httpServer.stop()
        grpcServer.stop()
        throw e
    }
}
