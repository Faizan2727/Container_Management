# Docker Management Tool

This is a Bash-based Docker management tool designed to simplify common Docker operations, including checking Docker installation, managing containers, creating volumes, and cleaning up resources. It provides an interactive menu for ease of use.

## Features

1. **Check Docker Installation**:
   - Detects if Docker is installed on your system.
   - Provides OS-specific installation instructions if Docker is not installed.

2. **List Containers**:
   - Lists all running containers.
   - Option to display all containers (including stopped ones).
   - Allows stopping a selected container.

3. **Create and Run a New Container**:
   - Prompts for container name, image, port mappings, volume mappings, environment variables, and restart policy.
   - Dynamically builds and executes the `docker run` command.

4. **Start a Stopped Container**:
   - Easily start any stopped container by providing its name or ID.

5. **Create and Attach a Volume**:
   - Creates a new Docker volume.
   - Attaches the volume to an existing container at a specified mount point.

6. **Clean Up Resources**:
   - Cleans up unused containers, images, networks, and volumes.

## Prerequisites

- Docker must be installed and properly configured on your system.
- `bash` shell and basic Linux utilities are required.

## How to Execute

1. Save the script to a file, e.g., `docker_tool.sh`.
2. Make the script executable:

   ```bash
   chmod +x docker_tool.sh
   ```

3. Run the script:

   ```bash
   ./docker_tool.sh
   ```

4. Follow the interactive menu to perform Docker operations.

## Interactive Menu

The tool provides the following menu options:

- **1. List All Containers**:
  - Displays running containers in a tabular format.
  - Option to include stopped containers in the list.

- **2. Create and Run a New Container**:
  - Guides the user through prompts to configure and launch a new container.

- **3. Start a Stopped Container**:
  - Starts a stopped container by its name or ID.

- **4. Clean the Resources**:
  - Performs a cleanup of unused Docker resources like containers, images, networks, and volumes.

- **5. Create Volume and Mount**:
  - Creates a new volume and attaches it to an existing container.

- **8. Exit**:
  - Exits the tool.

## Example Usage

1. **Check Docker Installation**:
   - If Docker is not installed, the tool provides specific instructions for your operating system.

2. **Create a New Container**:
   - Input image name, port mappings, and other options interactively.
   - Example command generated: `docker run -d --name my_container -p 8080:80 -e ENV_VAR=value nginx:latest`

3. **Attach Volume**:
   - Create a volume `my_volume` and attach it to container `my_container` at `/app/data`.

4. **Clean Up Resources**:
   - Automatically removes unused Docker containers, images, networks, and volumes.

## Notes

- This tool is designed to handle common Docker management tasks but does not cover advanced scenarios like multi-container orchestration.
- For unsupported distributions or operating systems, refer to [Docker's official documentation](https://docs.docker.com/engine/install/).

---

Enjoy simplified Docker management with this tool!

