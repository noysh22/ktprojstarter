load("@bazel_skylib//lib:dicts.bzl", "dicts")
load("@rules_jvm_external//:defs.bzl", "maven_install")
load("@rules_jvm_external//:specs.bzl", "maven", "parse")

MAVEN_DEPS = [
    "io.javalin:javalin:6.2.0",
    "org.slf4j:slf4j-simple:2.0.9",
    "junit:junit:4.13.2",
    "org.assertj:assertj-core:3.20.2",
    "io.netty:netty-all:4.1.87.Final",
    "com.google.guava:guava:jar:33.3.0-jre",
    "com.google.code.gson:gson:2.11.0",

    # kotlinx libs
    "org.jetbrains.kotlinx:kotlinx-coroutines-test:1.8.0",
    "org.jetbrains.kotlinx:kotlinx-coroutines-test-jvm:1.8.0",
    #    "org.jetbrains.kotlinx:kotlinx-coroutines-guave:1.8.0",

    # Ktor
    "io.ktor:ktor-client-core:2.3.12",
    "io.ktor:ktor-client-cio-jvm:2.3.12",
    "io.ktor:ktor-http-jvm:2.3.12",
]

MAVEN_SUPRESSED = [
]

MAVEN_OVERRIDES = {
    "org.jetbrains.kotlin:kotlin-reflect": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-reflect",
    "org.jetbrains.kotlin:kotlin-stdlib-jdk7": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-stdlib-jdk7",
    "org.jetbrains.kotlin:kotlin-stdlib-jdk8": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-stdlib-jdk8",
    "org.jetbrains.kotlin:kotlin-stdlib": "@io_bazel_rules_kotlin//kotlin/compiler:kotlin-stdlib",
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
        artifacts = remove_shadowed_deps(MAVEN_DEPS, MAVEN_SUPRESSED),
        version_conflict_policy = "pinned",
        generate_compat_repositories = True,
        override_targets = dicts.add(MAVEN_OVERRIDES),
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
