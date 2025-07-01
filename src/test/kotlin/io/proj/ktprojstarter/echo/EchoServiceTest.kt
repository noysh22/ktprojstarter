package io.proj.ktprojstarter.echo

import io.grpc.testing.GrpcCleanupRule
import io.grpc.inprocess.InProcessServerBuilder
import io.grpc.inprocess.InProcessChannelBuilder
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.test.runTest
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.TestInstance

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class EchoServiceTest {

    private val grpcCleanup = GrpcCleanupRule()
    private lateinit var stub: EchoServiceGrpcKt.EchoServiceCoroutineStub

    @BeforeEach
    fun setUp() {
        val serverName = InProcessServerBuilder.generateName()
        
        grpcCleanup.register(
            InProcessServerBuilder
                .forName(serverName)
                .directExecutor()
                .addService(EchoServer.EchoServiceImpl())
                .build()
                .start()
        )

        val channel = grpcCleanup.register(
            InProcessChannelBuilder.forName(serverName).directExecutor().build()
        )

        stub = EchoServiceGrpcKt.EchoServiceCoroutineStub(channel)
    }

    @Test
    fun `test unary echo returns correct response`() = runTest {
        // Given
        val request = EchoRequest.newBuilder()
            .setMessage("Hello, World!")
            .setRequestId(123)
            .build()

        // When
        val response = stub.echo(request)

        // Then
        assertThat(response.message).isEqualTo("Echo: Hello, World!")
        assertThat(response.requestId).isEqualTo(123)
        assertThat(response.timestamp).isGreaterThan(0)
    }

    @Test
    fun `test unary echo with empty message`() = runTest {
        // Given
        val request = EchoRequest.newBuilder()
            .setMessage("")
            .setRequestId(456)
            .build()

        // When
        val response = stub.echo(request)

        // Then
        assertThat(response.message).isEqualTo("Echo: ")
        assertThat(response.requestId).isEqualTo(456)
    }

    @Test
    fun `test server streaming echo returns multiple responses`() = runTest {
        // Given
        val request = EchoRequest.newBuilder()
            .setMessage("Stream me!")
            .setRequestId(789)
            .build()

        // When
        val responses = stub.serverStreamingEcho(request).toList()

        // Then
        assertThat(responses).hasSize(3)
        responses.forEachIndexed { index, response ->
            assertThat(response.message).isEqualTo("Echo $index: Stream me!")
            assertThat(response.requestId).isEqualTo(789)
            assertThat(response.timestamp).isGreaterThan(0)
        }
    }

    @Test
    fun `test client streaming echo concatenates messages`() = runTest {
        // Given
        val messages = listOf("First", "Second", "Third")
        val requests: Flow<EchoRequest> = messages.mapIndexed { index, message ->
            EchoRequest.newBuilder()
                .setMessage(message)
                .setRequestId(index + 1)
                .build()
        }.asFlow()

        // When
        val response = stub.clientStreamingEcho(requests)

        // Then
        assertThat(response.message).isEqualTo("Concatenated echo: First, Second, Third")
        assertThat(response.requestId).isEqualTo(3) // Last request ID
        assertThat(response.timestamp).isGreaterThan(0)
    }

    @Test
    fun `test client streaming echo with single message`() = runTest {
        // Given
        val requests: Flow<EchoRequest> = listOf(
            EchoRequest.newBuilder()
                .setMessage("Solo message")
                .setRequestId(999)
                .build()
        ).asFlow()

        // When
        val response = stub.clientStreamingEcho(requests)

        // Then
        assertThat(response.message).isEqualTo("Concatenated echo: Solo message")
        assertThat(response.requestId).isEqualTo(999)
    }

    @Test
    fun `test bidirectional streaming echo responds to each message`() = runTest {
        // Given
        val inputMessages = listOf("Bidirectional 1", "Bidirectional 2", "Bidirectional 3")
        val requests: Flow<EchoRequest> = flow {
            inputMessages.forEachIndexed { index, message ->
                emit(
                    EchoRequest.newBuilder()
                        .setMessage(message)
                        .setRequestId(index + 100)
                        .build()
                )
            }
        }

        // When
        val responses = stub.bidirectionalStreamingEcho(requests).toList()

        // Then
        assertThat(responses).hasSize(3)
        responses.forEachIndexed { index, response ->
            assertThat(response.message).isEqualTo("Bidirectional echo: ${inputMessages[index]}")
            assertThat(response.requestId).isEqualTo(index + 100)
            assertThat(response.timestamp).isGreaterThan(0)
        }
    }

    @Test
    fun `test bidirectional streaming echo with empty stream`() = runTest {
        // Given
        val requests: Flow<EchoRequest> = flow {
            // Empty flow - emit nothing
        }

        // When
        val responses = stub.bidirectionalStreamingEcho(requests).toList()

        // Then
        assertThat(responses).isEmpty()
    }

    @Test
    fun `test multiple concurrent unary echo calls`() = runTest {
        // Given
        val requests = (1..5).map { i ->
            EchoRequest.newBuilder()
                .setMessage("Concurrent message $i")
                .setRequestId(i)
                .build()
        }

        // When
        val responses = requests.map { request ->
            stub.echo(request)
        }

        // Then
        assertThat(responses).hasSize(5)
        responses.forEachIndexed { index, response ->
            assertThat(response.message).isEqualTo("Echo: Concurrent message ${index + 1}")
            assertThat(response.requestId).isEqualTo(index + 1)
        }
    }

    @Test
    fun `test echo with special characters`() = runTest {
        // Given
        val specialMessage = "Hello! @#$%^&*() 中文 émojis 🚀🎉"
        val request = EchoRequest.newBuilder()
            .setMessage(specialMessage)
            .setRequestId(42)
            .build()

        // When
        val response = stub.echo(request)

        // Then
        assertThat(response.message).isEqualTo("Echo: $specialMessage")
        assertThat(response.requestId).isEqualTo(42)
    }
}
