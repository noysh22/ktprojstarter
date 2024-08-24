load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# --- Skylib

http_archive(
    name = "bazel_skylib",
    sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# --- Aspect Bazel lib

ASPECT_BAZEL_LIB_TAG = "2.8.0"

ASPECT_BAZEL_LIB_SHA = "cea19e6d8322fb212f155acb58d1590f632e53abde7f1be5f0a086a93cf4c9f4"

# aspect_bazel_lib dependency
http_archive(
    name = "aspect_bazel_lib",
    sha256 = ASPECT_BAZEL_LIB_SHA,  # Replace with actual SHA256
    strip_prefix = "bazel-lib-%s" % ASPECT_BAZEL_LIB_TAG,
    urls = ["https://github.com/aspect-build/bazel-lib/releases/download/v%s/bazel-lib-v%s.tar.gz" % (ASPECT_BAZEL_LIB_TAG, ASPECT_BAZEL_LIB_TAG)],
)

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies", "aspect_bazel_lib_register_toolchains")

# Required bazel-lib dependencies
aspect_bazel_lib_dependencies()

# Register bazel-lib toolchains
aspect_bazel_lib_register_toolchains()

# --- Container structure tests

CONTAINER_STRUCTURE_TEST_TAG = "1.19.1"

CONTAINER_STRUCTURE_TEST_SHA = "b56a53fb7734f93216b60f8cdd3b98fbbd767e9f412c061d4fa4798e579c4971"

# container_structure_test dependency
http_archive(
    name = "container_structure_test",
    sha256 = CONTAINER_STRUCTURE_TEST_SHA,  # Replace with actual SHA256
    strip_prefix = "container-structure-test-%s" % CONTAINER_STRUCTURE_TEST_TAG,
    urls = ["https://github.com/GoogleContainerTools/container-structure-test/archive/refs/tags/v%s.tar.gz" % CONTAINER_STRUCTURE_TEST_TAG],
)

load("@container_structure_test//:repositories.bzl", "container_structure_test_register_toolchain")

container_structure_test_register_toolchain(name = "cst")

# --- Rules JVM external

RULES_JVM_EXTERNAL_TAG = "6.2"

RULES_JVM_EXTERNAL_SHA = "808cb5c30b5f70d12a2a745a29edc46728fd35fa195c1762a596b63ae9cebe05"

http_archive(
    name = "rules_jvm_external",
    sha256 = RULES_JVM_EXTERNAL_SHA,
    strip_prefix = "rules_jvm_external-%s" % RULES_JVM_EXTERNAL_TAG,
    url = "https://github.com/bazelbuild/rules_jvm_external/releases/download/%s/rules_jvm_external-%s.tar.gz" % (RULES_JVM_EXTERNAL_TAG, RULES_JVM_EXTERNAL_TAG),
)

load("@rules_jvm_external//:repositories.bzl", "rules_jvm_external_deps")

rules_jvm_external_deps()

load("@rules_jvm_external//:setup.bzl", "rules_jvm_external_setup")

rules_jvm_external_setup()

# --- Kotlin rules

rules_kotlin_version = "1.9.6"

rules_kotlin_sha = "3b772976fec7bdcda1d84b9d39b176589424c047eb2175bed09aac630e50af43"

http_archive(
    name = "io_bazel_rules_kotlin",
    sha256 = rules_kotlin_sha,
    urls = ["https://github.com/bazelbuild/rules_kotlin/releases/download/v%s/rules_kotlin-v%s.tar.gz" % (rules_kotlin_version, rules_kotlin_version)],
)

load("@io_bazel_rules_kotlin//kotlin:repositories.bzl", "kotlin_repositories")

kotlin_repositories()  # if you want the default. Otherwise see custom kotlinc distribution below

register_toolchains("//bazel:kotlin_toolchain")

# --- Maven deps

load("//bazel:maven.bzl", "maven_deps")

maven_deps()

load("@maven//:defs.bzl", "pinned_maven_install")

pinned_maven_install()

load("@maven//:compat.bzl", "compat_repositories")

compat_repositories()

# --- OCI rules

RULES_OCI_TAG = "2.0.0-beta2"

RULES_OCI_SHA = "311e78803a4161688cc79679c0fb95c56445a893868320a3caf174ff6e2c383b"

# rules_oci dependency
http_archive(
    name = "rules_oci",
    sha256 = RULES_OCI_SHA,
    strip_prefix = "rules_oci-%s" % RULES_OCI_TAG,
    url = "https://github.com/bazel-contrib/rules_oci/releases/download/v%s/rules_oci-v%s.tar.gz" % (RULES_OCI_TAG, RULES_OCI_TAG),
)

load("@rules_oci//oci:dependencies.bzl", "rules_oci_dependencies")

rules_oci_dependencies()

load("@rules_oci//oci:repositories.bzl", "oci_register_toolchains")

oci_register_toolchains(name = "oci")

# You can pull your base images using oci_pull like this:
load("@rules_oci//oci:pull.bzl", "oci_pull")

# Load the containers from 3rd/containers.bzl
load("//bazel:containers.bzl", "load_containers")

load_containers()
