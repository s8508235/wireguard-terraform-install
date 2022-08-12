# set repo url and file #
export rwfile="/etc/yum.repos.d/wireguard.repo"
export rwurl="https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo"
# Download it
sudo wget --output-document="$rwfile" "$rwurl"