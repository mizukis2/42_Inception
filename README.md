*This project has been created as part of the 42 curriculum by mmatsui*
# Inception - 42
## Description
This project aims to broaden my knowledge of system administration by using Docker.<br>
The project involves creating and running several Docker images within a new personal virtual machine.
Three mandatory Docker images must be created: NGINX, MariaDB, and WordPress. As a bonus, I added another Docker image to run Adminer.<br>
Once all containers are built and running, it is possible to access the default WordPress pages and the Adminer web interface through a web browser.<br>

## Project description
### Virtual Machines vs Docker
While virtual machines contain an entire operating system, which makes them heavier to build and run, Docker containers share the host's kernel.<br>
Instead of including a complete operating system for each container, Docker packages the application and its required dependencies. This makes containers generally faster to start and smaller than virtual machines.<br>
Virtual machines provide stronger isolation because each VM has its own operating system and kernel. Docker containers are more lightweight because they share the host kernel, while still providing process and filesystem isolation between containers.<br>

### Secrets vs Environment Variables
In the context of this project, Docker Compose uses environment variables defined in the `.env` file located in the project directory.<br>
Environment variables are useful for configuration values that do not need to be kept secret. However, sensitive information such as credentials, API keys, and passwords should not be stored directly in `.env`, especially if the file could be exposed or committed to a Git repository.<br>
For sensitive information, I use Docker secrets instead. I designed the project to handle secrets as follows:<br>
- A `secrets` directory is created, and passwords are generated automatically when running the `Makefile`.
- The secret files are provided to the relevant containers through Docker Compose secrets and are made available inside the containers under `/run/secrets/`.
- When running `make fdown`, the `secrets` directory is removed.
- The `secrets` directory is included in `.gitignore`, so the secret files are not tracked by Git.
This approach keeps sensitive credentials separate from regular configuration values and helps prevent them from being accidentally committed to the repository.

### Docker Network vs Host Network
By default, Docker containers use an isolated Docker network. Each container has its own network namespace and can communicate with other containers through the Docker network.<br>
In this project, NGINX, WordPress, MariaDB, and Adminer are connected to the same Docker network. This allows them to communicate with each other using their container or service names instead of exposing every service directly to the host.<br>
For example, NGINX can communicate with WordPress through the WordPress service name and port, while WordPress can communicate with MariaDB through the MariaDB service name and port.<br>
The host network mode is different. When a container uses the host network, it shares the host's network namespace instead of having its own isolated network. This removes some of Docker's network isolation and makes the container use the host's network interfaces directly.<br>
Using a dedicated Docker network is therefore useful in this project because it provides network isolation between the containers while allowing the services that need to communicate with each other to do so.<br>
```
                         Docker Network: inception
        ┌─────────────────────────────────────────────────┐
        │                                                 │
        │   NGINX                                         │
        │    │                                            │
        │    ├────── FastCGI :9000 ──→ WordPress/PHP-FPM  │
        │    │                              │             │
        │    │                              │ MySQL :3306 │
        │    │                              ↓             │
        │    │                           MariaDB          │
        │    │                                            │
        │    └────── FastCGI :9000──→ Adminer/PHP-FPM     │
        │                                    │            │
        │                                    │ MySQL :3306│ 
        │                                    ↓            │
        │                                 MariaDB         │
        │                                                 │
        └─────────────────────────────────────────────────┘
                         │
                         │ published ports
                         │
                  :443   │    :8080
                 |       ↓       |
                 |  Host / VM    |
                 |       │       |
                 |       ↓       | 
          (WordPress)  Browser  (Adminer)
```
Port 443 is the published port for NGINX's WordPress endpoint, while port 8080 is the published port for NGINX's Adminer endpoint. NGINX receives the browser request and forwards PHP requests through FastCGI to PHP-FPM on port 9000. Both the WordPress and Adminer containers use port 9000 internally because they are separate containers.<br>

MariaDB uses port 3306 for MySQL connections. WordPress and Adminer both connect to MariaDB through port 3306 over the Docker network. Port 3306 does not need to be published to the Host because these containers can communicate with MariaDB directly through the Docker network using the MariaDB service name.<br>

### Docker Volumes vs Bind Mounts
Both Docker volumes and bind mounts allow data to persist outside the container's writable layer. This means that data can remain available even if a container is stopped, removed, or recreated.<br>
A Docker volume is managed by Docker. Docker decides where the data is stored on the host, and the user normally interacts with the volume through Docker commands.<br>
A bind mount maps a specific file or directory from the host filesystem into a container. The user controls the exact location of the data on the host.<br>
In this project, I use Docker volumes to persist the WordPress, MariaDB and Adminer data. This ensures that the website files and database data are not lost when the containers are recreated.<br>

## Instructions

### 1. Clone the project

Clone the repository inside the Virtual Machine:

```bash
git clone git@github.com:mizukis2/42_Inception.git
cd 42_Inception
```

### 2. Build and run the containers

Build the Docker images and start the containers:

```bash
make build
```

### 3. Access the services

This project provides two web services through the same domain with different HTTPS ports.

#### WordPress

Open a web browser and go to:

```text
https://mmatsui.42.fr:443
```

Port `443` is the standard HTTPS port, so `:443` can also be omitted:

```text
https://mmatsui.42.fr
```

This will display the WordPress website.

#### Adminer

To access Adminer, use port `8080`:

```text
https://mmatsui.42.fr:8080
```

This will open the Adminer web interface for managing the MariaDB database.

Because the project uses a self-signed TLS certificate, the browser may display a warning such as:

> Warning: Potential Security Risk Ahead

Click **Advanced...** and then **Accept the Risk and Continue**.

### 4. Stop and clean up the project

To stop the containers and remove the project's containers and persistent data:

```bash
make fdown
```

For more detailed information, see:

* `USER_DOC.md` — information for users
* `DEV_DOC.md` — information for developers


## 🔎Resources
- [実践 Docker - ソフトウェアエンジニアの「Docker よくわからない」を終わりにする本](https://zenn.dev/suzuki_hoge/books/2022-03-docker-practice-8ae36c33424b59)
- [Docker Crash Course for Absolute Beginners [NEW]](https://youtu.be/pg19Z8LL06w?si=Lc_gRG-VePTIQuu-)
- [dockerdocs](https://docs.docker.com/)
- [How to install WordPress](https://make.wordpress.org/cli/handbook/how-to/how-to-install/)
- [Advanced Administration Handbook](https://developer.wordpress.org/advanced-administration/)
- [nginx documentation](https://nginx.org/en/docs/)
- [How to set up Adminer with Docker to manage databases](https://www.hostinger.com/ca/tutorials/how-to-set-up-adminer-docker/)


AI tools [ChatGPT](https://chatgpt.com/) and [Claude](https://claude.ai/) were used for:
- Clarifying key concepts
- Structuring the README
- Reviewing explanations for clarity
All configurations and problem-solving were completed manually.
All AI-generated explanations were reviewed and understood before inclusion.
