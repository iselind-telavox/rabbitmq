#!/bin/sh -x

ACTION="$1"
MYNS="$2"
OTHERNS="$3"

deployment_folder="deployment/${MYNS}"

rm -rf "${deployment_folder}"
mkdir -p "${deployment_folder}"

cp template/* "${deployment_folder}"

find "${deployment_folder}" -type f -print0 \
    | xargs -0 sed -i '' \
        -e "s/#MYNS#/${MYNS}/" \
        -e "s/#OTHERNS#/${OTHERNS}/"

kubectl --namespace "${MYNS}" "${ACTION}" -R -f "${deployment_folder}"

if [ "${ACTION}" = "delete" ]; then
    rm -rf "${deployment_folder}"
fi
