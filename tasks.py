from invoke import task

ARCHITECTURES = [
    "amd64",
    "arm32v7",
    "arm64v8",
]

DOCKER_REPOSITORY = "hannahsfamily/unifi-controller"

STABLE_VERSION = "5.12.35"
IMAGE_VERSION = "1"


@task(iterable=["architectures"])
def build(c,
          version=STABLE_VERSION,
          image_version=IMAGE_VERSION,
          architectures=[],
          repository=DOCKER_REPOSITORY):
    if len(architectures) == 0:
        architectures = ARCHITECTURES.copy()

    tag = "{}:{}-{}-$TARGET".format(repository, version, image_version)
    cmd = [
        "docker", "build", "-t", tag, "--build-arg", "\"target=$TARGET\"",
        "--build-arg", "\"version={}\"".format(version), "."
    ]

    for target in architectures:
        env = {"TARGET": target}
        c.run(" ".join(cmd), env=env, pty=True)


@task(iterable=["architectures"])
def push(c,
         version=STABLE_VERSION,
         image_version=IMAGE_VERSION,
         architectures=[],
         repository=DOCKER_REPOSITORY):
    if len(architectures) == 0:
        architectures = ARCHITECTURES.copy()

    tag = "{}:{}-{}-$TARGET".format(repository, version, image_version)
    cmd = ["docker", "push", tag]

    for target in architectures:
        env = {"TARGET": target}
        c.run(" ".join(cmd), env=env, pty=True)


@task(iterable=["architectures"])
def manifest(c,
             version=STABLE_VERSION,
             image_version=IMAGE_VERSION,
             tag=None,
             architectures=[],
             repository=DOCKER_REPOSITORY):
    if len(architectures) == 0:
        architectures = ARCHITECTURES.copy()

    if tag is None:
        tag = "{}:{}-{}".format(repository, version, image_version)

    cmd = ["docker", "manifest", "create", tag]
    cmd.extend("{}:{}-{}-{}".format(repository, version, image_version, target)
               for target in architectures)
    c.run(" ".join(cmd), pty=True)
    c.run("docker manifest push --purge {}".format(tag), pty=True)


@task(build, push, manifest)
def all(c):
    pass
