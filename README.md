<a href="#build-minimal-freeswitch-docker-images">
    <img loading="lazy" src="https://raw.github.com/rtckit/media/master/slimswitch/readme-splash.png" alt="slimswitch" class="width-full">
</a>

# Build minimal FreeSWITCH Docker images

[![Docker Pulls](https://img.shields.io/docker/pulls/rtckit/slimswitch-builder.svg)](https://hub.docker.com/r/rtckit/slimswitch-builder)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

Tooling for creating lean FreeSWITCH Docker images; resulting containers are efficient and expose a reduced attack surface. This is achieved by layering only the FreeSWITCH core, select modules and their runtime dependencies.

## Quickstart

Decide which FreeSWITCH modules should be included and provide a basic XML core/modules configuration file!

```sh
git clone https://github.com/rtckit/slimswitch.git
cd slimswitch

./bin/mkslim.sh \
    -m mod_commands -m mod_dptools -m mod_sofia \
    -s local/awesome-switch
docker run --rm -it \
    -v "$(pwd)/freeswitch.xml":/etc/freeswitch/freeswitch.xml \
    local/awesome-switch:v1.10.7
```

![Quickstart](https://raw.github.com/rtckit/media/master/slimswitch/demo.gif)

## Requirements

[Docker](https://docs.docker.com/get-docker/) and [docker-slim](https://dockersl.im/install.html) must be installed in the building environment.

## How it works

A generic reusable [builder image](etc/Dockerfile) is created first; the goal is to build the FreeSWITCH core and most of its modules, so then they can be mixed-and-matched as needed. The resulting image can also serve as a base for compiling third party modules. This phase is handled by the [./bin/mkbuilder.sh](./bin/mkbuilder.sh) script. Images corresponding to official FreeSWITCH releases are also [publicly available](https://hub.docker.com/r/rtckit/slimswitch-builder).

The trimming is achieved via the [./bin/mkslim.sh](./bin/mkslim.sh) script, which is essentially a wrapper for docker-slim; specifically, it leverages its static analysis features so dynamic dependencies are accounted for when the final image is created.

## License

MIT, see [LICENSE file](LICENSE).

### Acknowledgments

* [FreeSWITCH](https://github.com/signalwire/freeswitch), FreeSWITCH is a registered trademark of Anthony Minessale II
* [Docker](https://docker.com), Docker is a registered trademark of Docker, Inc
* [docker-slim](https://github.com/docker-slim/docker-slim)

### Contributing

Bug reports (and small patches) can be submitted via the [issue tracker](https://github.com/rtckit/slimswitch/issues). Forking the repository and submitting a Pull Request is preferred for substantial patches.
