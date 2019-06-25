from invoke import task

ARCHITECTURES = [
    "amd64",
    "arm32v7",
    "arm64v8",
]

DOCKER_REPOSITORY = "hannahsfamily/unifi-controller"

STABLE_VERSION = "5.10.25"


@task(iterable=["architectures"])
def build(c,
          version=STABLE_VERSION,
          architectures=[],
          repository=DOCKER_REPOSITORY):
    if len(architectures) == 0:
        architectures = ARCHITECTURES.copy()

    tag = "{}:{}-$TARGET".format(repository, version)
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
         architectures=[],
         repository=DOCKER_REPOSITORY):
    if len(architectures) == 0:
        architectures = ARCHITECTURES.copy()

    cmd = ["docker", "push"]

    for target in architectures:
        c.run(" ".join([*cmd, "{}:{}-{}".format(repository, version, target)]),
              pty=True)


@task(iterable=["architectures"])
def manifest(c,
             version=STABLE_VERSION,
             architectures=[],
             repository=DOCKER_REPOSITORY):
    if len(architectures) == 0:
        architectures = ARCHITECTURES.copy()

    cmd = ["docker", "manifest", "create", "{}:{}".format(repository, version)]
    cmd.extend("{}:{}-{}".format(repository, version, target)
               for target in architectures)
    c.run(" ".join(cmd), pty=True)
    c.run("docker manifest push --purge {}:{}".format(repository, version),
          pty=True)
