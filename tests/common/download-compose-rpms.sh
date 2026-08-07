#!/bin/bash
# Source this file to get the download_compose_rpms helper function.

# download_compose_rpms <packages_url> <dest_dir>
#
# Downloads the latest greenboot and greenboot-default-health-checks RPMs
# from the compose packages index at <packages_url> into <dest_dir>.
#
# The packages index page is fetched once and reused for both lookups.
#
# The -k (--insecure) flag is required because RHEL internal compose servers
# use certificates signed by the Red Hat internal CA, which is not present
# in the default system trust store on CI hosts.
download_compose_rpms() {
    local packages_url="$1"
    local dest_dir="$2"

    # The packages index page can be huge (thousands of RPMs). Silence xtrace
    # while we fetch/parse it so its raw HTML isn't dumped into the CI logs.
    { set +x; } 2>/dev/null

    local packages_page
    packages_page="$(curl -kfsSL --retry 5 --retry-delay 2 --retry-all-errors \
        "${packages_url}")"

    local greenboot_rpm
    greenboot_rpm="$(echo "${packages_page}" \
        | grep -oE 'greenboot-[0-9][^"]*\.rpm' \
        | grep -vE 'debug(info|source)' \
        | sort -V | tail -n 1)"
    if [[ -z "${greenboot_rpm}" ]]; then
        set -x
        echo "ERROR: greenboot RPM not found at ${packages_url}"
        return 1
    fi
    echo "Selected greenboot RPM: ${greenboot_rpm}"

    local greenboot_default_rpm
    greenboot_default_rpm="$(echo "${packages_page}" \
        | grep -oE 'greenboot-default-health-checks-[0-9][^"]*\.rpm' \
        | sort -V | tail -n 1)"
    if [[ -z "${greenboot_default_rpm}" ]]; then
        set -x
        echo "ERROR: greenboot default RPM not found at ${packages_url}"
        return 1
    fi
    echo "Selected greenboot-default-health-checks RPM: ${greenboot_default_rpm}"
    set -x

    curl -kfsSL --retry 5 --retry-delay 2 --retry-all-errors \
        "${packages_url}${greenboot_rpm}" -o "${dest_dir}/${greenboot_rpm}"
    curl -kfsSL --retry 5 --retry-delay 2 --retry-all-errors \
        "${packages_url}${greenboot_default_rpm}" -o "${dest_dir}/${greenboot_default_rpm}"
}
