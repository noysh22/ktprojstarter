load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("@aspect_bazel_lib//lib:tar.bzl", "tar")
load("@container_structure_test//:defs.bzl", "container_structure_test")
load("@io_bazel_rules_kotlin//kotlin:core.bzl", "define_kt_toolchain", "kt_kotlinc_options")
load("@io_bazel_rules_kotlin//kotlin:jvm.bzl", "kt_jvm_binary", "kt_jvm_library", "kt_jvm_test")
load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load")

package(default_visibility = ["//visibility:public"])

PROJ_NAME = "ktprojstarter"

kt_kotlinc_options(
    name = "kt_kotlinc_options",
    warn = "report",
)

define_kt_toolchain(
    name = "kotlin_toolchain",
    api_version = "2.1",
    experimental_multiplex_workers = True,
    jvm_target = "21",
    kotlinc_options = "//:kt_kotlinc_options",
    language_version = "2.1",
)

# Main Kotlin library
kt_jvm_library(
    name = PROJ_NAME + "_lib",
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

# Java binary (executable JAR with all dependencies)
java_binary(
    name = PROJ_NAME,
    main_class = "io.proj.ktprojstarter.MainKt",
    runtime_deps = [
        ":%s_lib" % PROJ_NAME,
    ],
)

# Single test definition that collects all test files
kt_jvm_test(
    name = PROJ_NAME + "_tests",
    args = [
        "--scan-classpath",  # Discovers all tests in the classpath
        # Optional: Include custom test name patterns (e.g., *Should.kt)
        "--include-classname=.*(Test|Should)",
    ],
    main_class = "org.junit.platform.console.ConsoleLauncher",
    deps = [
        ":%s_lib" % PROJ_NAME,
        "@maven//:com_google_code_gson_gson",
        "@maven//:io_ktor_ktor_client_cio_jvm",
        "@maven//:io_ktor_ktor_client_core",
        "@maven//:io_ktor_ktor_http_jvm",
        "@maven//:org_assertj_assertj_core",
        "@maven//:org_jetbrains_kotlinx_kotlinx_coroutines_test",
        "@maven//:org_jetbrains_kotlinx_kotlinx_coroutines_test_jvm",
        "@maven//:org_junit_jupiter_junit_jupiter",
        "@maven//:org_junit_jupiter_junit_jupiter_params",
        "@maven//:org_junit_platform_junit_platform_console",
    ],
)

tar(
    name = PROJ_NAME + "_layer",
    srcs = [":%s_deploy.jar" % PROJ_NAME],
)

oci_image(
    name = PROJ_NAME + "_image",
    base = "@java-21-distroless-debug",
    entrypoint = [
        "java",
        "-jar",
        "/%s_deploy.jar" % PROJ_NAME,
    ],
    tars = [":%s_layer" % PROJ_NAME],
)

# template for tagging oci images with git hash of current HEAD
expand_template(
    name = PROJ_NAME + "_stamped",
    out = PROJ_NAME + "_stamped.tags.txt",
    stamp = 1,
    stamp_substitutions = {
        "{STABLE_GIT_HASH_SHORT}": "{{STABLE_GIT_HASH_SHORT}}",
    },
    template = [
        PROJ_NAME + ":{STABLE_GIT_HASH_SHORT}",
        PROJ_NAME + ":latest",
    ],
)

oci_load(
    name = PROJ_NAME + "_load",
    image = ":%s_image" % PROJ_NAME,
    repo_tags = ":%s_stamped" % PROJ_NAME,
)

# Container structure test (platform auto-detected)
container_structure_test(
    name = PROJ_NAME + "_container_test",
    args = select({
        "@platforms//cpu:arm64": [
            "--platform",
            "linux/arm64/v8",
        ],
        "@platforms//cpu:x86_64": [
            "--platform",
            "linux/amd64",
        ],
        "//conditions:default": [
            "--platform",
            "linux/amd64",
        ],
    }),
    configs = ["container-structure-test.yaml"],
    image = ":%s_image" % PROJ_NAME,
    tags = ["requires-docker"],
)
