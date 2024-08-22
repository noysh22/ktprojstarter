load("@com_github_grpc_grpc_kotlin//:kt_jvm_grpc.bzl", "kt_jvm_grpc_library", "kt_jvm_proto_library")
load("@rules_proto//proto:defs.bzl", "proto_library")

proto_library(
    name = "ktprojstarter_proto",
    srcs = ["ktprojstarter.proto"],
)

kt_jvm_proto_library(
    name = "ktprojstarter_kt_proto",
    deps = [":ktprojstarter_proto"],
)

kt_jvm_grpc_library(
    name = "ktprojstarter_kt_grpc",
    srcs = [":ktprojstarter_proto"],
    deps = [":ktprojstarter_kt_proto"],
)
