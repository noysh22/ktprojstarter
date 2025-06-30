#load("@rules_oci//oci:container.bzl", "oci_image")
# You can pull your base images using oci_pull like this:
load("@bazel_skylib//lib:modules.bzl", "modules")
load("@rules_oci//oci:pull.bzl", "oci_pull")

images = [
    # openjdk version "21.0.4" 2024-07-16 LTS
    # OpenJDK Runtime Environment Temurin-21.0.4+7 (build 21.0.4+7-LTS)
    {
        "name": "java-21-distroless-nonroot",
        "registry": "gcr.io",
        "repository": "distroless/java21-debian12",
        "tag": "noroot",
        "platforms": [
            "linux/amd64",
            "linux/arm64/v8",
        ],
    },
    {
        "name": "java-21-distroless-debug",
        "registry": "gcr.io",
        "repository": "distroless/java21-debian12",
        "tag": "debug",
        "platforms": [
            "linux/amd64",
            "linux/arm64/v8",
        ],
    },
]

def _pull_containers():
    for image in images:
        oci_pull(
            name = image["name"],
            registry = image["registry"],
            repository = image["repository"],
            tag = image["tag"] if "digest" not in image else None,
            digest = image.get("digest", None),
            platforms = image.get("platforms", None),
        )

pull_containers = modules.as_extension(_pull_containers)
