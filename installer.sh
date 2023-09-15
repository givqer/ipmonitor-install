#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

APP_PATH="/opt/ipmonitor"
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

    echo "$docker_version"

}


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

if check_folder "$APP_PATH"; then
 echo "Project folder exists and is not empty."
 cd /opt/ipmonitor || exit
 echo "We should stop existing stack if it's running. Please, be sure to backup your data if you are upgrading your version"
 sudo -E docker-compose -f docker-compose.yml stop &> /dev/null || true
else
  echo "Project folder does not exist or is empty."
  sudo mkdir -p $APP_PATH
  sudo chown "$(whoami)":"$(whoami)" $APP_PATH
  cd $APP_PATH || exit
  git clone --branch install https://github.com/givqer/ipmonitor-install.git .
fi

echo "Checking if .env file exists. If it doesn't exist, copy from template"
if [ ! -f ${APP_PATH}/.env ]; then
  cp ${APP_PATH}/.env.install ${APP_PATH}/.env
fi

#echo "Checking if docker installed, if installed, what version is installed"
#check_docker_version
#if [ -z "$(check_docker_version)" ]; then
#  echo "docker isn't installed";
#  echo ""
#  echo "Proceed to install docker "
#fi
#
cd ${APP_PATH} | exit
cat ~/pass.txt | docker login https://index.docker.io/v1/ --username alexbazdnc --password-stdin

make dc-init-app







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
    # Verify that Docker is installed and running
    docker --version
    sudo usermod -aG docker "$USER"
}





