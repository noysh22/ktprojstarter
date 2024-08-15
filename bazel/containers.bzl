#load("@rules_oci//oci:container.bzl", "oci_image")
# You can pull your base images using oci_pull like this:
load("@rules_oci//oci:pull.bzl", "oci_pull")

def load_containers():
    oci_pull(
        name = "distroless_java_debug",
        digest = "sha256:2e235d2103a25f4e2c353cfa3d06503594a8762dcd8578baa14d410bc0221c38",
        image = "gcr.io/distroless/java17",
    )
    oci_pull(
        name = "distroless_java_debug_noroot",
        digest = "sha256:b8eda5703e42fda1f599946490dad58b5187c24c1397395132e276a9399887af",
        image = "gcr.io/distroless/java17",
    )
    oci_pull(
        name = "distroless_java_noroot",
        digest = "sha256:005351f8825ee898a7207140267277c401d779648fb6f0575acfa408c959f902",
        image = "gcr.io/distroless/java17",
    )
