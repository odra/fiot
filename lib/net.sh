if [ "${BASH_SOURCE[0]}" -ef "$0" ]; then
    echo 'This should should be sourced, not executed.'
    exit 1
fi

net::download() {
    local url=$1
    local dest=$2

    if [ -z "${url}" ]; then
        echo "Provide an url."
        exit 1
    fi

    if [ -z "${dest}" ]; then
        echo "Provide a path destination"
        exit 1
    fi

    wget -c -O $dest $url
}
