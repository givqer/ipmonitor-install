#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

APP_PATH="/opt/ipmonitor"
DOCKER_REQ_VERSION="24"

echo "Update apt cache and install tools:"
sudo apt update
sudo apt install make git -y;
echo ""
echo "Preparing working dir"
echo "Checking application folder if it exists, if not, create dir and git clone installer repo"

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
  echo ""
  echo "Before we start, please, edit .environment file to correct your data from preset values to your own:"
  echo ""
  nano .env

fi

if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    # Install Docker using the official script (for Linux)
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    # Start and enable the Docker service (for Linux)
    sudo systemctl enable docker
    sudo systemctl start docker
    rm get-docker.sh
    echo "Docker has been installed."
    echo ""
    echo "Add user to docker group:"
    sudo -E usermod -aG docker "$USER"
    echo "Done"
    # Check Docker version
    docker_version=$(sudo docker --version  2>&1)
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
            echo "Exiting script."
            exit 1
        fi

    fi
        cd ${APP_PATH} || exit
        cat /home/ubuntu/pass.txt | sudo -E docker login https://index.docker.io/v1/ --username alexbazdnc --password-stdin
        sudo -E make dc-first-install-app
fi

