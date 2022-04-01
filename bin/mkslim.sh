#!/bin/sh

ETC_PATH="`dirname $0`"/../etc

. ${ETC_PATH}/config.sh

if [ ! -x "$(command -v docker)" ]; then
    printf "Cannot find docker\n"
    exit 1
fi

if [ ! -x "$(command -v docker-slim)" ]; then
    printf "Cannot find docker-slim\n"
    exit 1
fi

SLIM_REPOSITORY=""
MODULE_FLAGS=""
INCLUDE_FLAGS=""

# Process arguments
while :; do
    case $1 in
        -t)
            if [ -n "$2" ]; then
                FREESWITCH_TAG=$2
                shift
            else
                printf "Cannot pass -t without FreeSWITCH tag argument (e.g. ${FREESWITCH_TAG})\n" >&2
                exit 1
            fi
            ;;
        -r)
            if [ -n "$2" ]; then
                BUILDER_REPOSITORY=$2
                shift
            else
                printf "Cannot pass -r without builder Docker image repository name argument (e.g. ${BUILDER_REPOSITORY})\n" >&2
                exit 1
            fi
            ;;
        -s)
            if [ -n "$2" ]; then
                SLIM_REPOSITORY=$2
                shift
            else
                printf "Cannot pass -s without slim Docker image repository name argument\n" >&2
                exit 1
            fi
            ;;
        -m)
            if [ -n "$2" ]; then
                MODULE_FLAGS="${MODULE_FLAGS} --include-exe=/usr/lib/freeswitch/mod/$2.so"
                shift
            else
                printf "Cannot pass -m without FreeSWSITCH module name argument (e.g. mod_commands)\n" >&2
                exit 1
            fi
            ;;
        -i)
            if [ -n "$2" ]; then
                INCLUDE_FLAGS="${INCLUDE_FLAGS} --include-path=$2"
                shift
            else
                printf "Cannot pass -i without include path argument (e.g. /usr/share/freeswitch/sounds)\n" >&2
                exit 1
            fi
            ;;
        -h)
            printf "slimswitch mkslim.sh utility\n"
            printf "https://github.com/rtckit/slimswitch\n\n"
            printf "Usage: %s [-t <FreeSWITCH tag>] [-r <Builder image repository>] [-s <Slim image repository>] [-m <FreeSWITCH module>] [-i <Path>]\n" "$0"
            printf "\t-t Builder image tag (default: %s)\n" "${FREESWITCH_TAG}"
            printf "\t-r Builder image repository (default: %s)\n" "${BUILDER_REPOSITORY}"
            printf "\t-s Slim image repository (e.g. -s my-org/telco-project)\n"
            printf "\t-m FreeSWITCH module, can be used multiple times (e.g. -m mod_mariadb -m mod_shout)\n"
            printf "\t-i Keep path from builder image, can be used multiple times (e.g. -i /usr/share/freeswitch/sounds)\n"
            exit 0
            ;;
        -?*)
            printf "Unknown argument %s\n" "$1" >&2
            exit 1
            ;;
        *)
            break
    esac

    shift
done

docker image inspect ${BUILDER_REPOSITORY}:${FREESWITCH_TAG} > /dev/null 2>&1
LOCAL_BUILDER=$?

if [ $LOCAL_BUILDER -ne 0 ]; then
    printf "Local builder image not found, checking public DockerHub images ...\n"

    curl --silent -f -lSL https://index.docker.io/v1/repositories/${BUILDER_REPOSITORY}/tags/${FREESWITCH_TAG} > /dev/null 2>&1
    DOCKERHUB_BUILDER=$?

    if [ $DOCKERHUB_BUILDER -ne 0 ]; then
        printf "Builder image not found on DockerHub, creating it locally ...\n"
        "`dirname $0`"/mkbuilder.sh
    else
        printf "Pulling builder image from DockerHub ...\n"
        docker pull ${BUILDER_REPOSITORY}:${FREESWITCH_TAG}
    fi
else
    printf "Using local builder docker image ...\n"
fi

if [ -z "$SLIM_REPOSITORY" ]; then
    SLIM_REPOSITORY=$(printf '%s' "$BUILDER_REPOSITORY" | sed -e 's/-builder/-slim/g')
fi

docker-slim build \
    --http-probe-off \
    --continue-after 1 \
    --include-cert-all \
    --entrypoint=/bin/true \
    --include-bin=/lib/x86_64-linux-gnu/libnss_dns.so.2 \
    --include-exe=/usr/bin/freeswitch ${MODULE_FLAGS} \
    ${INCLUDE_FLAGS} \
    --exclude-pattern=/bin/true \
    --target ${BUILDER_REPOSITORY}:${FREESWITCH_TAG} \
    --tag ${SLIM_REPOSITORY}:${FREESWITCH_TAG}
