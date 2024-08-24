load("@aspect_bazel_lib//lib:expand_template.bzl", "expand_template")
load("@aspect_bazel_lib//lib:tar.bzl", "tar")
load("@container_structure_test//:defs.bzl", "container_structure_test")
load("@io_bazel_rules_kotlin//kotlin:jvm.bzl", "kt_jvm_library", "kt_jvm_test")
load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")
load("@rules_oci//oci:defs.bzl", "oci_image", "oci_load")

package(default_visibility = ["//visibility:public"])

PROJ_NAME = "ktprojstarter"

java_binary(
    name = PROJ_NAME,
    data = [
    ],
    main_class = "io.proj.ktprojstarter.MainKt",
    runtime_deps = [
        ":%s_lib" % PROJ_NAME,
    ],
)

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

java_library(
    name = PROJ_NAME + "_java_test_deps",
    testonly = True,
    exports = [
        "@maven//:io_javalin_javalin",
        "@maven//:junit_junit",
        "@maven//:org_assertj_assertj_core",
    ],
)

kt_jvm_library(
    name = PROJ_NAME + "_kotlin_test_deps",
    testonly = True,
    srcs = glob(["src/test/kotlin/**/*.kt"]),
    deps = [
        ":%s_java_test_deps" % PROJ_NAME,
    ],
)

kt_jvm_test(
    name = PROJ_NAME + "_kt_tests",
    srcs = glob(["src/test/kotlin/**/*.kt"]),
    test_class = "io.proj.ktprojstarter.ExampleTest",
    deps = [
        ":%s_kotlin_test_deps" % PROJ_NAME,
    ],
)

java_test(
    name = PROJ_NAME + "_tests",
    test_class = "io.proj.ktprojstarter.ExampleTest",
    runtime_deps = [
        ":%s_kotlin_test_deps" % PROJ_NAME,
    ],
)

tar(
    name = PROJ_NAME + "_layer",
    srcs = [PROJ_NAME + "_deploy.jar"],
)

oci_image(
    name = PROJ_NAME + "_image",
    base = "@distroless_java_debug",
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

#container_structure_test(
#    name = PROJ_NAME + "_container_test",
#    configs = ["container-structure-test.yaml"],
#    image = ":%s_image" % PROJ_NAME,
#    tags = ["requires-docker"],
#)
