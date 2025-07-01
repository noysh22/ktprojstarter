load("@com_github_grpc_grpc_kotlin//:kt_jvm_grpc.bzl", "kt_jvm_grpc_no_java_library", "kt_jvm_proto_library")
load("@com_google_protobuf//bazel:proto_library.bzl", "proto_library")
load("@io_grpc_grpc_java//:java_grpc_library.bzl", "java_grpc_library")

package(default_visibility = ["//visibility:public"])

proto_library(
    name = "echo_proto",
    srcs = ["echo.proto"],
)

kt_jvm_proto_library(
    name = "echo_kt_proto",
    deps = [":echo_proto"],
)

java_grpc_library(
    name = "echo_grpc_java",
    srcs = [":echo_proto"],
    deps = [":echo_kt_proto"],
)

kt_jvm_grpc_no_java_library(
    name = "echo_kt_grpc",
    srcs = [":echo_proto"],
    java_grpc_dep = ":echo_grpc_java",  # Java gRPC dependency
    deps = [":echo_kt_proto"],
)
