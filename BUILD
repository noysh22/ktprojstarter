load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")
load("@rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library")

package(default_visibility = ["//visibility:public"])

java_binary(
    name = "server",
    data = [
    ],
    main_class = "io.proj.MainKt",
    runtime_deps = [
        ":server_lib",
    ],
)

kt_jvm_library(
    name = "server_lib",
    srcs = glob(
        include = [
            "src/main/kotlin/**/*.kt",
        ],
    ),
    deps = [
        "@maven//:io_javalin_javalin",
        "@maven//:org_slf4j_slf4j_simple",
    ],
)

java_library(
    name = "java_test_deps",
    testonly = True,
    exports = [
        "@maven//:io_javalin_javalin",
        "@maven//:junit_junit",
        "@maven//:org_assertj_assertj_core",
    ],
)

kt_jvm_library(
    name = "kotlin_test_deps",
    testonly = True,
    srcs = glob(["src/test/kotlin/**/*.kt"]),
    deps = [
        ":java_test_deps",
    ],
)

java_test(
    name = "tests",
    test_class = "io.proj.ExampleTest",
    runtime_deps = [
        ":kotlin_test_deps",
    ],
)
