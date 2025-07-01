package io.proj.ktprojstarter.echo

import io.grpc.ManagedChannel
import io.grpc.ManagedChannelBuilder
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.runBlocking
import java.util.concurrent.TimeUnit
import java.util.logging.Logger

/**
 * gRPC Echo Client implementation using Kotlin coroutines
 */
class EchoClient(host: String, port: Int) {
    private val logger = Logger.getLogger(EchoClient::class.java.name)
    
    private val channel: ManagedChannel = ManagedChannelBuilder
        .forAddress(host, port)
        .usePlaintext()
        .build()
    
    private val stub = EchoServiceGrpcKt.EchoServiceCoroutineStub(channel)

    suspend fun echo(message: String, requestId: Int = 1): EchoResponse {
        val request = EchoRequest.newBuilder()
            .setMessage(message)
            .setRequestId(requestId)
            .build()
        
        logger.info("Sending echo request: $message")
        return stub.echo(request)
    }

    suspend fun serverStreamingEcho(message: String, requestId: Int = 1) {
        val request = EchoRequest.newBuilder()
            .setMessage(message)
            .setRequestId(requestId)
            .build()
        
        logger.info("Sending server streaming echo request: $message")
        stub.serverStreamingEcho(request).collect { response ->
            logger.info("Received streaming response: ${response.message}")
        }
    }

    suspend fun clientStreamingEcho(messages: List<String>) {
        val requests: Flow<EchoRequest> = messages.mapIndexed { index, message ->
            EchoRequest.newBuilder()
                .setMessage(message)
                .setRequestId(index + 1)
                .build()
        }.asFlow()
        
        logger.info("Sending client streaming echo request with ${messages.size} messages")
        val response = stub.clientStreamingEcho(requests)
        logger.info("Received client streaming response: ${response.message}")
    }

    suspend fun bidirectionalStreamingEcho(messages: List<String>) {
        val requests: Flow<EchoRequest> = flow {
            messages.forEachIndexed { index, message ->
                emit(
                    EchoRequest.newBuilder()
                        .setMessage(message)
                        .setRequestId(index + 1)
                        .build()
                )
                kotlinx.coroutines.delay(500) // Small delay between messages
            }
        }
        
        logger.info("Sending bidirectional streaming echo request with ${messages.size} messages")
        stub.bidirectionalStreamingEcho(requests).collect { response ->
            logger.info("Received bidirectional streaming response: ${response.message}")
        }
    }

    fun shutdown() {
        channel.shutdown().awaitTermination(5, TimeUnit.SECONDS)
    }
}

/**
 * Main function to test the echo client
 */
fun main() = runBlocking {
    val client = EchoClient("localhost", 9090)
    
    try {
        // Test unary echo
        val response = client.echo("Hello, gRPC!")
        println("Unary echo response: ${response.message}")
        
        // Test server streaming echo
        println("\nTesting server streaming echo:")
        client.serverStreamingEcho("Stream this message")
        
        // Test client streaming echo
        println("\nTesting client streaming echo:")
        client.clientStreamingEcho(listOf("Message 1", "Message 2", "Message 3"))
        
        // Test bidirectional streaming echo
        println("\nTesting bidirectional streaming echo:")
        client.bidirectionalStreamingEcho(listOf("Bidirectional 1", "Bidirectional 2"))
        
    } finally {
        client.shutdown()
    }
}
