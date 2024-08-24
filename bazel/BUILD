load("@io_bazel_rules_kotlin//kotlin:core.bzl", "define_kt_toolchain", "kt_kotlinc_options")

kt_kotlinc_options(
    name = "kt_kotlinc_options",
    warn = "report",
)

define_kt_toolchain(
    name = "kotlin_toolchain",
    api_version = "1.9",
    jvm_target = "21",
    kotlinc_options = ":kt_kotlinc_options",
    language_version = "1.9",
)
