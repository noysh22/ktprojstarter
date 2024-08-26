package io.proj.ktprojstarter

import com.google.gson.Gson
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.coroutines.runBlocking
import org.assertj.core.api.Assertions.assertThat
import org.junit.*

data class TestData(val msg: String)

@Suppress("FunctionName")
class ExampleTest {
    lateinit var client: HttpClient
    val json = Gson()

    companion object {
        private val port = 7070
        private val server = Server(port)

        @JvmStatic
        @BeforeClass
        fun setupTests() {
            server.start()
        }

        @JvmStatic
        @AfterClass
        fun teardownTests() {
            server.stop()
        }

        fun baseUrl() = "http://localhost:${server.port}"
    }

    @Before
    fun setup() {
        client = HttpClient(CIO)
    }

    @After
    fun teardown() {
        client.close()
    }

    @Test
    fun `hello world`() {
        assertThat(1).isEqualTo(1)
    }

    @Test
    fun `test GET request`() {
        val resp = runBlocking {
            client.get(baseUrl())
        }

        assertThat(resp.status).isEqualTo(HttpStatusCode.OK)
        runBlocking {
            assertThat(resp.bodyAsText()).isEqualTo("Welcome")
        }
    }

    @Test
    fun `test POST request`() {
        val payload = TestData("This is a test msg")
        runBlocking {
            val resp = client.post("${baseUrl()}/echo") {
                contentType(ContentType.Application.Json)
                setBody(json.toJson(payload))
            }

            val dataFromResp = json.fromJson(resp.bodyAsText(), TestData::class.java)
            assertThat(payload.msg).isEqualTo(dataFromResp.msg)
        }
    }
}
