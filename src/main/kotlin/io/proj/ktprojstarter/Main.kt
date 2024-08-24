package io.proj.ktprojstarter

import io.javalin.Javalin

fun main() {
    Javalin.create(/*config*/)
        .get("/") { ctx -> ctx.result("Hello World") }
        .start(7070)
}
