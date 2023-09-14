#!/usr/bin/env bash
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

