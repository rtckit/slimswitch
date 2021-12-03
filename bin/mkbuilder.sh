#!/bin/sh

ETC_PATH="`dirname $0`"/../etc

. ${ETC_PATH}/config.sh

if [ ! -x "$(command -v docker)" ]; then
    printf "Cannot find docker\n"
    exit 1
fi

# Process arguments
while :; do
    case $1 in
        -d)
            if [ -n "$2" ]; then
                DEBIAN_RELEASE=$2
                shift
            else
                printf "Cannot pass -d without Debian release argument (e.g. ${DEBIAN_RELEASE})\n" >&2
                exit 1
            fi
            ;;
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
        -h)
            printf "slimswitch mkbuilder.sh utility\n"
            printf "https://github.com/rtckit/slimswitch\n\n"
            printf "Usage: %s [-d <Debian release>] [-t <FreeSWITCH tag>] [-r <Builder image repository>]\n" "$0"
            printf "\t-d Base Debian image tag (default: %s)\n" "${DEBIAN_RELEASE}"
            printf "\t-t Builder image tag (default: %s)\n" "${FREESWITCH_TAG}"
            printf "\t-r Builder image repository (default: %s)\n" "${BUILDER_REPOSITORY}"
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

docker build \
    --build-arg FREESWITCH_TAG=${FREESWITCH_TAG} \
    -t ${BUILDER_REPOSITORY}:${FREESWITCH_TAG} \
    -f ${ETC_PATH}/Dockerfile ${ETC_PATH}
