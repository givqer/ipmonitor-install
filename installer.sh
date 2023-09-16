#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

APP_PATH="/opt/ipmonitor"
DOCKER_REQ_VERSION="24"
	check_folder() {
    if [[ -z $1 ]]; then
        echo "Error: Folder path not provided."
        return 1
    fi

    local folder_path="$1"

    if [[ -d $folder_path && -n $(ls -A "$folder_path") ]]; then
        return 0
    else
        return 1
    fi
}

#	check_docker_version() {
#    if ! command -v docker &> /dev/null; then
#        echo "Error: Docker is not installed."
#        return 1
#    fi
#
#    local docker_version=$(docker version --format '{{.Server.Version}}' 2>&1)
#    if [[ $? -ne 0 ]]; then
#        echo "Error: Failed to retrieve Docker version."
#        return 1
#    fi
#
#    echo "$docker_version"
#
#}



#echo "We need your sudo session to proceed. Thanks a lot"
#if [ $EUID != 0 ]; then
#    sudo "$0" "$@"
#    exit $?
#fi


echo "Update apt cache and install tools:"
#sudo apt update
#sudo apt install make git -y;
echo ""
echo "Preparing working dir"
echo "Checking application folder if it exists, just pull git reporsitory to update version, if not, create dir and git clone installer repo"
echo "..."

if [[ -d $APP_PATH && -n $(ls -A "$APP_PATH") ]]; then
 echo "Project folder exists and is not empty."
 cd /opt/ipmonitor || exit
 echo "We should stop existing stack if it's running. Please, be sure to backup your data if you are upgrading your version"
 sudo -E docker-compose -f docker-compose.yml stop &> /dev/null || true
else
  echo "Project folder does not exist or is empty."
  sudo mkdir -p $APP_PATH
  echo "Folder $APP_PATH created."
  sudo chown -R "$(whoami)":"$(whoami)" $APP_PATH
  echo "Folder $APP_PATH chowned by current user: $(whoami)"
  cd $APP_PATH || exit
  echo "Switched to working directory"
  git clone --branch install https://github.com/givqer/ipmonitor-install.git .
  echo "Cloned installer files from public repository into $APP_PATH"
  cp .env.install .env
fi

#echo ""
#echo "===================Docker section ======================="
#
# Check if Docker is already installed


if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    # Install Docker using the official script (for Linux)
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh --version 23.0 --channel stable
    # Start and enable the Docker service (for Linux)
    sudo systemctl start docker
    sudo systemctl enable docker
    # Clean up the installation script
    rm get-docker.sh
    echo "Docker has been installed."

    echo ""
    echo "Add user to docker group:"
    sudo -E usermod -aG docker "$USER"
    echo "Done"
    # Check Docker version
    docker_version=$(docker --version  2>&1)
    echo "Docker version: $docker_version"
fi



if command -v docker &> /dev/null; then
    docker_version=$(docker --version | awk '{print $3}' | cut -d ',' -f1)
    required_version=${DOCKER_REQ_VERSION}  # Define the required major version as a string
    echo $required_version
    # Extract the major version from the Docker version string
    installed_major_version=$(echo "$docker_version" | cut -d '.' -f1)

    if [ "$installed_major_version" -lt "$required_version" ]; then
        read -r -p "The installed Docker version may not be compatible with this script. Do you want to proceed? (yes/no): " proceed
        if [ "$proceed" != "yes" ]; then

        fi
    fi
cd ${APP_PATH} || exit
make dc-first-install-app
fi


#  echo "Checking if .env file exists. If it doesn't exist, copy from template"
#    if [ ! -f ${APP_PATH}/.env ]; then
#      cp ${APP_PATH}/.env.install ${APP_PATH}/.env || exit
#      echo "Template .env copied to .env"
#    fi

#echo ""
#echo "===================Docker section ======================="
#
#echo "Checking if docker installed, if installed, what version is installed"
#check_docker_version
##if [ -z "$(check_docker_version)" ]; then
##  echo "docker isn't installed";
##  echo ""
##  dockerinstalled=0
##fi
#if [ -z "$(check_docker_version)" ]; then
#echo "installing docker:"
##from official docs here: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
## Add Docker's official GPG key:
#sudo apt-get install ca-certificates curl gnupg
#sudo install -m 0755 -d /etc/apt/keyrings
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#sudo chmod a+r /etc/apt/keyrings/docker.gpg
#
## Add the repository to Apt sources:
#echo \
#  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
#  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
#  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#sudo apt-get update
#sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
#echo "Docker version installed: $(check_docker_version)"
#fi
#
#
#cd ${APP_PATH} || exit
#cat ~/pass.txt | docker login https://index.docker.io/v1/ --username alexbazdnc --password-stdin
#
#make dc-init-app
