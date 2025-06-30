"""Handy helper functions for Java and Kotlin rules."""

load("@contrib_rules_jvm//java:defs.bzl", "java_junit5_test")

def _test_name(test_class):
    """Creates the testname from the full java class name."""
    parts = test_class.split(".")

    # The name of kotlin classes always ends with kt, so ignore that and return the second to last identifier
    if (parts[len(parts) - 1] == "kt" and len(parts) > 1):
        return parts[len(parts) - 2]
    return parts[len(parts) - 1]

def _path2pkg(path):
    """Extract the java and kotlin package path"""
    if ("/java/" in path):
        return _javapath2pkg(path)
    if ("/kotlin/" in path):
        return _kotlinpath2pkg(path)
    fail("unsupported directory layout: %s" % (path))

def _stripKtOrJavaSuffix(path):
    if path.endswith(".java"):
        return path.removesuffix(".java")
    elif path.endswith(".kt"):
        return path.removesuffix(".kt")
    else:
        return path

def _kotlinpath2pkg(path):
    """Creates a full class name from the path to a .kt or .java file.

    Assumes that the path matches a normal kotlin directory layout.
    Ex.
        path: src/main/java/com/foo/Bar.kt
        pkg: com.foo.Bar

    Ex.
        path: src/test/java/com/foo/Bar.kt
        pkg: com.foo.Bar
    """
    parts = path.split("src/main/kotlin/")
    if len(parts) == 1:
        parts = path.split("src/test/kotlin/")

    if len(parts) != 2 and parts[0] != "":
        fail("unsupported directory layout:%s" % (path))

    clean_path = _stripKtOrJavaSuffix(parts[1])
    return clean_path.replace("/", ".")

def _javapath2pkg(path):
    """Creates a full class name from the path to a .java or .kt file.

    Assumes that the path matches a normal java directory layout.
    Ex.
        path: src/main/java/com/foo/Bar.java
        pkg: com.foo.Bar

    Ex.
        path: src/test/java/com/foo/Bar.java
        pkg: com.foo.Bar
    """
    parts = path.split("src/main/java/")
    if len(parts) == 1:
        parts = path.split("src/test/java/")

    if len(parts) != 2 and parts[0] != "":
        fail("unsupported directory layout:%s" % (path))

    clean_path = _stripKtOrJavaSuffix(parts[1])
    return clean_path.replace("/", ".")

def glob2pkg(include, exclude = []):
    """Creates full class names from the .java paths after glob expansion."""
    return [_path2pkg(path) for path in native.glob(include, exclude = exclude)]

def java_junit5_tests(
        name,
        test_classes,
        runtime_deps,
        rule_name_prefix = "",
        size = None,
        timeout = None,
        jvm_flags = [],
        tags = None,
        flaky = 0,
        visibility = None,
        data = None,
        local = False):
    """Emits java_test rules for every class in test_classes."""
    generated = []

    for cls in test_classes:
        test_name = rule_name_prefix + _test_name(cls)
        generated.append(test_name)
        java_junit5_test(
            name = test_name,
            flaky = flaky,
            size = size,
            timeout = timeout,
            test_class = cls,
            runtime_deps = runtime_deps,
            jvm_flags = jvm_flags,
            tags = tags,
            visibility = visibility,
            data = data,
            local = local,
        )

    native.test_suite(
        name = name,
        tests = generated,
    )
