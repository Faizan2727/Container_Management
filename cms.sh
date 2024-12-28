check_docker() {
    echo "Checking if Docker is installed on your system..."

    # Check if Docker command exists
    if command -v docker &> /dev/null; then
        echo "✅ Docker is already installed on your system."
        docker --version
    else
        echo "❌ Docker is not installed on your system."
        echo "Detecting your operating system to suggest installation steps..."

        # Detect the operating system
        OS=$(uname -s)
        case "$OS" in
            Linux)
                # Further detect Linux distribution
                if [ -f /etc/os-release ]; then
                    . /etc/os-release
                    OS_NAME=$ID
                    echo "You are using a Linux distribution: $NAME"
                    
                    case "$OS_NAME" in
                        ubuntu|debian)
                            echo "Run the following commands to install Docker on $NAME:"
                            echo "  sudo apt update"
                            echo "  sudo apt install -y docker.io"
                        ;;
                        centos|rhel|fedora)
                            echo "Run the following commands to install Docker on $NAME:"
                            echo "  sudo dnf install -y docker"
                            echo "  sudo systemctl start docker"
                            echo "  sudo systemctl enable docker"
                        ;;
                        arch)
                            echo "Run the following command to install Docker on $NAME:"
                            echo "  sudo pacman -S docker"
                        ;;
                        *)
                            echo "Unsupported Linux distribution. Refer to Docker's official documentation for installation steps."
                            echo "URL: https://docs.docker.com/engine/install/"
                        ;;
                    esac
                else
                    echo "Cannot determine your Linux distribution. Refer to Docker's official documentation for installation steps."
                    echo "URL: https://docs.docker.com/engine/install/"
                fi
            ;;
            Darwin)
                echo "You are using macOS. Use the following command to install Docker:"
                echo "  brew install --cask docker"
                echo "Make sure Homebrew is installed. If not, install it from https://brew.sh/"
            ;;
            CYGWIN*|MINGW32*|MSYS*|MINGW*)
                echo "You are using Windows. Install Docker Desktop from:"
                echo "  https://www.docker.com/products/docker-desktop"
            ;;
            *)
                echo "Unsupported operating system. Refer to Docker's official documentation for installation steps."
                echo "URL: https://docs.docker.com/engine/install/"
            ;;
        esac
    fi
}

show_menu(){
	echo "Docker Management System"
	echo "Press 1 to List All Containers:"
	echo "Press 2 create new container and run:"
	echo "Press 3 Start a stopped container:"
	echo "Press 4 clean the resouces:"
	echo "Press 5 create volume and mount"
	echo "Press 8 Exit:"

}

list_containers() {
    echo "Listing all running Docker containers..."
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

    echo -n "Do you want to list all containers (including stopped ones)? (yes/no): "
    read list_all_choice

    if [[ "$list_all_choice" == "yes" ]]; then
        echo "Listing all containers (including stopped):"
        docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
    fi

    echo -n "Do you want to stop a container? (yes/no): "
    read stop_choice

    if [[ "$stop_choice" == "yes" ]]; then
        echo -n "Enter the name or ID of the container to stop: "
        read container_id
        docker stop "$container_id"
        echo "Container $container_id has been stopped."
    else
        echo "No containers were stopped."
    fi
}


create_new_container() {
    echo "Let's create a new Docker container!"

    # Prompt for container name
    echo -n "Enter a name for the new container (leave blank for auto-generated): "
    read container_name

    # Prompt for Docker image
    echo -n "Enter the image to use (e.g., nginx:latest): "
    read image_name
    if [ -z "$image_name" ]; then
        echo "❌ Docker image is mandatory. Exiting..."
        return 1
    fi

    # Prompt for port mappings
    echo -n "Enter port mapping (e.g., 8080:80) or leave blank to skip: "
    read port_mapping

    # Prompt for volume mapping
    echo -n "Enter volume mapping (e.g., my_volume:/app) or leave blank to skip: "
    read volume_mapping

    # Prompt for environment variables
    echo -n "Enter environment variables (e.g., ENV_VAR=value, separate multiple with spaces) or leave blank to skip: "
    read -a env_vars

    # Prompt for restart policy
    echo -n "Enter restart policy (e.g., always, unless-stopped, no) or leave blank for 'no': "
    read restart_policy
    if [ -z "$restart_policy" ]; then
        restart_policy="no"
    fi

    # Prompt for detaching or running interactively
    echo -n "Do you want to run the container in detached mode? (yes/no): "
    read detached_choice
    if [[ "$detached_choice" == "yes" ]]; then
        detach_flag="-d"
    else
        detach_flag="-it"
    fi

    # Build the Docker run command dynamically
    run_command="docker run"

    # Add container name if specified
    if [ -n "$container_name" ]; then
        run_command+=" --name $container_name"
    fi

    # Add port mapping if specified
    if [ -n "$port_mapping" ]; then
        run_command+=" -p $port_mapping"
    fi

    # Add volume mapping if specified
    if [ -n "$volume_mapping" ]; then
        run_command+=" --mount source=$(echo $volume_mapping | cut -d':' -f1),target=$(echo $volume_mapping | cut -d':' -f2)"
    fi

    # Add environment variables if specified
    if [ ${#env_vars[@]} -gt 0 ]; then
        for env_var in "${env_vars[@]}"; do
            run_command+=" -e $env_var"
        done
    fi

    # Add restart policy
    run_command+=" --restart $restart_policy"

    # Add detach or interactive flag
    run_command+=" $detach_flag"

    # Add the image name
    run_command+=" $image_name"

    # Run the final command
    echo "Running the following Docker command:"
    echo "$run_command"
    eval "$run_command"

    if [ $? -eq 0 ]; then
        echo "✅ Docker container created successfully!"
    else
        echo "❌ Failed to create Docker container. Please check the error above."
    fi
}


start_container() {
	read -n "enter your stopped container name:" stopped_container
	docker start $stopped_container
}

create_and_attach_volume() {
    echo "Creating a Docker volume and attaching it to a container..."

    # Prompt for the volume name
    echo -n "Enter the name of the volume to create: "
    read volume_name

    # Create the Docker volume
    if docker volume create "$volume_name" &> /dev/null; then
        echo "✅ Docker volume '$volume_name' created successfully."
    else
        echo "❌ Failed to create Docker volume '$volume_name'. Please check for errors."
        return 1
    fi

    # List available containers
    echo "Here are the available containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"

    # Prompt for the container name or ID
    echo -n "Enter the name or ID of the container to attach the volume to: "
    read container_name

    # Check if the container exists
    if ! docker inspect "$container_name" &> /dev/null; then
        echo "❌ Container '$container_name' not found. Please check the name or ID."
        return 1
    fi

    # Prompt for the mount point inside the container
    echo -n "Enter the mount point inside the container (e.g., /app/data): "
    read mount_point

    # Stop the container before modifying it
    echo "Stopping container '$container_name'..."
    docker stop "$container_name"

    # Re-run the container with the volume attached
    echo "Re-running container '$container_name' with volume '$volume_name' attached..."
    container_image=$(docker inspect --format='{{.Config.Image}}' "$container_name")

    docker rm "$container_name"  # Remove the container
    docker run -d --name "$container_name" --mount source="$volume_name",target="$mount_point" "$container_image"

    if [ $? -eq 0 ]; then
        echo "✅ Volume '$volume_name' successfully attached to container '$container_name' at '$mount_point'."
    else
        echo "❌ Failed to re-run container '$container_name' with the volume. Please check for errors."
    fi
}

cleanup() {
    echo "Starting Docker cleanup..."
    docker container prune -f
    docker image prune -f
    docker network prune -f
    docker volume prune -f
    echo "Docker cleanup completed."
}



while :; do
	check_docker
	show_menu
	read -p "Choose in Options:" choice
       	case $choice in
		1) list_containers;; 
		2) create_new_container;;
		3) start_container;;
		4) cleanup;;
		5) create_and_attach_volume;;
		8) echo "Goodbye buddy" 
		exit ;;

	esac
done	

