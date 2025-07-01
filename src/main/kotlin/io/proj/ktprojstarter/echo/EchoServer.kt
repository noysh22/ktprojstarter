package io.proj.ktprojstarter.echo

import io.grpc.Server
import io.grpc.ServerBuilder
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import java.util.concurrent.TimeUnit
import java.util.logging.Logger

/**
 * gRPC Echo Server implementation using Kotlin coroutines
 */
class EchoServer(private val port: Int) {
    private val logger = Logger.getLogger(EchoServer::class.java.name)
    private var server: Server? = null

    fun start() {
        server = ServerBuilder.forPort(port)
            .addService(EchoServiceImpl())
            .build()
            .start()
        
        logger.info("Echo server started, listening on port $port")
        
        Runtime.getRuntime().addShutdownHook(Thread {
            logger.info("*** shutting down gRPC server since JVM is shutting down")
            stop()
            logger.info("*** server shut down")
        })
    }

    fun stop() {
        server?.shutdown()?.awaitTermination(30, TimeUnit.SECONDS)
    }

    fun blockUntilShutdown() {
        server?.awaitTermination()
    }

    /**
     * Implementation of the Echo gRPC service using Kotlin coroutines
     */
    class EchoServiceImpl : EchoServiceGrpcKt.EchoServiceCoroutineImplBase() {
        private val logger = Logger.getLogger(EchoServiceImpl::class.java.name)

        override suspend fun echo(request: EchoRequest): EchoResponse {
            logger.info("Received echo request: ${request.message}")
            return EchoResponse.newBuilder()
                .setMessage("Echo: ${request.message}")
                .setRequestId(request.requestId)
                .setTimestamp(System.currentTimeMillis())
                .build()
        }

        override fun serverStreamingEcho(request: EchoRequest): Flow<EchoResponse> = flow {
            logger.info("Received server streaming echo request: ${request.message}")
            repeat(3) { i ->
                emit(
                    EchoResponse.newBuilder()
                        .setMessage("Echo $i: ${request.message}")
                        .setRequestId(request.requestId)
                        .setTimestamp(System.currentTimeMillis())
                        .build()
                )
                delay(1000) // 1 second delay between messages
            }
        }

        override suspend fun clientStreamingEcho(requests: Flow<EchoRequest>): EchoResponse {
            logger.info("Received client streaming echo request")
            val messages = mutableListOf<String>()
            var lastRequestId = 0
            
            requests.collect { request ->
                messages.add(request.message)
                lastRequestId = request.requestId
                logger.info("Received streaming message: ${request.message}")
            }
            
            return EchoResponse.newBuilder()
                .setMessage("Concatenated echo: ${messages.joinToString(", ")}")
                .setRequestId(lastRequestId)
                .setTimestamp(System.currentTimeMillis())
                .build()
        }

        override fun bidirectionalStreamingEcho(requests: Flow<EchoRequest>): Flow<EchoResponse> = flow {
            logger.info("Received bidirectional streaming echo request")
            requests.collect { request ->
                logger.info("Echoing back: ${request.message}")
                emit(
                    EchoResponse.newBuilder()
                        .setMessage("Bidirectional echo: ${request.message}")
                        .setRequestId(request.requestId)
                        .setTimestamp(System.currentTimeMillis())
                        .build()
                )
            }
        }
    }
}

/**
 * Main function to start the echo server
 */
fun main() {
    val port = System.getenv("GRPC_PORT")?.toIntOrNull() ?: 9090
    val server = EchoServer(port)
    server.start()
    server.blockUntilShutdown()
}
