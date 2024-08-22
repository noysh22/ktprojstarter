load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@com_github_grpc_grpc_kotlin//:repositories.bzl", "IO_GRPC_GRPC_KOTLIN_ARTIFACTS", "IO_GRPC_GRPC_KOTLIN_OVERRIDE_TARGETS")
load("@io_grpc_grpc_java//:repositories.bzl", "IO_GRPC_GRPC_JAVA_ARTIFACTS", "IO_GRPC_GRPC_JAVA_OVERRIDE_TARGETS", "grpc_java_repositories")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven", "parse")

MAVEN_DEPS = [
    "io.javalin:javalin:5.6.1",
    "org.slf4j:slf4j-simple:2.0.9",
    "junit:junit:4.13.2",
    "org.assertj:assertj-core:3.20.2",
    #    "io.netty:netty-all:4.1.87.Final",
    "com.google.guava:guava:jar:33.3.0-jre",
    "com.google.protobuf:protobuf-kotlin:3.25.3",
    #    "com.google.protobuf:protobuf-java:3.25.3",
    #    "com.google.protobuf:protobuf-java-util:3.25.3",
    #    "com.squareup:kotlinpoet:1.14.2",  # for grpc-kotlin
    #    "org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.0",
    #    "org.jetbrains.kotlinx:kotlinx-coroutines-test-jvm:1.8.0",
    #    "org.jetbrains.kotlinx:kotlinx-coroutines-guave:1.8.0",
]

MAVEN_SUPRESSED = [
    #    "com.squareup.okhttp:okhttp:",  # Prefer com.squareup.okhttp3:okhttp
]

MAVEN_OVERRIDES = {
    "org.jetbrains.kotlin:kotlin-reflect": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-reflect",
    "org.jetbrains.kotlin:kotlin-stdlib-jdk7": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-stdlib-jdk7",
    "org.jetbrains.kotlin:kotlin-stdlib-jdk8": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-stdlib-jdk8",
    "org.jetbrains.kotlin:kotlin-stdlib": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-stdlib",
    "io.netty:netty": "@maven//:io_netty_netty_all",
    #
    #    # Make sure there are no log4j dependencies included.
    #    "org.slf4j:slf4j-log4j12": "@maven//:ch_qos_logback_logback_core",
    #    "log4j:log4j": "@maven//:org_slf4j_log4j_over_slf4j",
}

def remove_shadowed_deps(deps, suppress):
    """Remove shadowed dependencies"""
    artifacts = parse.parse_artifact_spec_list(deps)
    filtered = []
    seen = dict(zip(suppress, suppress))
    for artifact in artifacts:
        name = ":".join([artifact["group"], artifact["artifact"], artifact.get("classifier", "")])
        if seen.get(name) == None:
            seen[name] = artifact
            filtered.append(artifact)
    return filtered

def maven_deps():
    maven_install(
        artifacts = remove_shadowed_deps(MAVEN_DEPS + IO_GRPC_GRPC_JAVA_ARTIFACTS + IO_GRPC_GRPC_KOTLIN_ARTIFACTS, MAVEN_SUPRESSED),
        version_conflict_policy = "pinned",
        generate_compat_repositories = True,
        override_targets = dicts.add(IO_GRPC_GRPC_JAVA_OVERRIDE_TARGETS, IO_GRPC_GRPC_KOTLIN_OVERRIDE_TARGETS, MAVEN_OVERRIDES),
        fail_if_repin_required = True,
        maven_install_json = "//bazel:maven_install.json",
        repositories = [
            "https://repo1.maven.org/maven2/",
            "https://jcenter.bintray.com/",
            "https://maven.google.com",
            "https://repository.jboss.org/nexus/content/repositories/releases/",
            "https://repository.jboss.org/nexus/content/repositories/thirdparty-releases/",
            "https://repository.jboss.org",
            "https://jitpack.io",
        ],
    )
