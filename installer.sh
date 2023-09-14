#!/usr/bin/env bash
#include functions.sh
# Full path of the current script
#THIS=`readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || echo $0`
#DIR=`dirname "${THIS}"`
#source "$DIR/functions.sh"
#echo ${DIR}


APP_PATH=/opt/ipmonitor
set -e

	check_folder() {
    if [[ -z $1 ]]; then
        echo "Error: The folder_path parameter is required."
        return 1
    fi

    local folder_path="$1"

    if [[ ! -d $folder_path ]]; then
        echo "Folder does not exist."
        return 1
    fi

    if [[ -z $(ls -A $folder_path) ]]; then
        echo "Folder is empty."
        return 1
    fi

    return 0
}

	check_docker_version() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed."
        return 1
    fi

    local docker_version=$(docker version --format '{{.Server.Version}}' 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to retrieve Docker version."
        return 1
    fi

    echo $docker_version

}

	install_latest_docker() {
    # Check if the user has root privileges
    if [[ $EUID -ne 0 ]]; then
        echo "Error: This function requires root privileges."
        return 1
    fi

    # Update the package lists
   sudo apt-get update

    # Install required packages to allow apt to use a repository over HTTPS
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    # Add Docker's stable repository
   sudo  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Update the package lists (again) to include the Docker packages
   sudo apt-get update

    # Install the latest version of Docker
   sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    # Verify that Docker is installed and running
    docker --version
    sudo usermod -aG docker $USER
}



#export  IPMONITOR_APP_TAG="${IPMONITOR_APP_TAG:-latest}"
##export SENTRY_DSN="${SENTRY_DSN:-'https://public@sentry.example.com/1'}"
#
#IPMONITOR_SECRET=$(head -c 28 /dev/urandom | sha224sum -b | head -c 56)
#export IPMONITOR_SECRET
#
## Talk to the user
#echo "Welcome to the single instance IPMonitor installer"
#echo ""
#echo "You need at leasr 4Gb RAM to run this stack"
#echo ""
#echo "Power user or aspiring power user?"
#echo "Check out our docs on deploying IPMonitor! https://linkhere/"
#echo ""
#
#
##Download specified release or use latest
#if ! [ -z "$1" ]
#then
#export IPMONITOR_APP_TAG=$1
#else
#echo "What version of IPMonitor would you like to install? (We default to 'latest')"
#echo "You can check out available versions here: https://hub.docker.com/r/ipmonitor/ipmonitor-app/tags"
#read -r IPMONITOR_APP_TAG_READ
#if [ -z "$IPMONITOR_APP_TAG_READ" ]
#then
#    echo "Using default and installing $IPMONITOR_APP_TAG"
#else
#    export IPMONITOR_APP_TAG=$IPMONITOR_APP_TAG_READ
#    echo "Using provided tag: $IPMONITOR_APP_TAG"
#fi
#fi
#echo ""
#
#
###Read domain name from user, which user  set for instance and start certificate installation for this domain
##if ! [ -z "$2" ]
##then
##export DOMAIN=$2
##else
##echo "Let's get the exact domain IPMonitor will be installed on"
##echo "Make sure that you have a Host A DNS record pointing to this instance!"
##echo "This will be used for TLS 🔐"
##echo "ie: test.IPMONITOR.net (NOT an IP address)"
##read -r DOMAIN
##export DOMAIN=$DOMAIN
##
##
##
##
##fi
##echo "Ok we'll set up certs for https://$DOMAIN"
##echo ""
##echo "We will need sudo access so the next question is for you to give us superuser access"
##echo "Please enter your sudo password now:"
##sudo echo ""
##echo "Thanks! 🙏"
##echo ""
##echo "Ok! We'll take it from here 🚀"
##
##echo "Making sure any stack that might exist is stopped"
##sudo -E docker compose -f docker-compose.yml stop &> /dev/null || true
echo "We need your sudo session to proceed. Thanks a lot"
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
echo "Preparing working dir"

echo "Update apt cache and install tools:"
sudo apt update
sudo apt install make git -y

echo "Checking application folder if it exists, just pull git reporsitory to update version, if not, create dir and git clone installer repo"
check_folder ${APP_PATH}
if [[ $? -eq 0 ]]; then
    echo "Project folder exists and is not empty."
#  sudo mv ${APP_PATH} /opt/ipmonitor-bak
    cd ${APP_PATH}
    git pull
else
  echo "Project folder does not exist or is empty."
  sudo mkdir -p ${APP_PATH}
  cd ${APP_PATH}
  sudo chown $(whoami):$(whoami) ${APP_PATH}
  git clone --branch install git@github.com:givqer/ipmonitor-install.git .
fi

ls -la ${APP_PATH}

echo "Checking if .env file exists. If it doesn't exist, copy from template"
if [ ! -f ${APP_PATH}/.env ]; then
  cp ${APP_PATH}/.env.install ${APP_PATH}/.env
fi

echo "Checking if docker installed, if installed, what version is installed"
check_docker_version
if [ -z "$(check_docker_version)" ]; then
  echo "docker isn't installed";
  echo ""
  echo "Proceed to install docker "
fi

#cd ${APP_PATH}
#cat ~/docker-pass.txt | docker login https://index.docker.io/v1/ --username alexbazdnc --password-stdin

#make dc-init-app













