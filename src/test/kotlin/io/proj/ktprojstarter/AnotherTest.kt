package io.proj.ktprojstarter

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.io.File

@Suppress("FunctionName")
class AnotherTest {
    @Test
    fun `another test`() {
        assertThat(1).isEqualTo(1)
    }

    @Test
    fun `test file example`() {
        val fileContent = File("src/test/resources/test.txt").readText()
        assertThat(fileContent).isNotNull
        assertThat(fileContent).contains("this is a test file")
    }
}
