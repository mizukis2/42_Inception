# Developer Documentation

## Virtual Machine Setup

This project is developed and run inside a Virtual Machine.

### Requirements

* Install VirtualBox.
* Download the Debian 64-bit PC (amd64) netinst ISO.
* Create a new Virtual Machine in VirtualBox.

### Virtual Machine Configuration

When creating the Virtual Machine:

* Select `debian-12.x.x-amd64-netinst.iso` as the installation image.
* Set a username and password.
* Allocate `4096 MB (4 GB)` of RAM.
* Allocate `2 CPUs`.

These settings may need to be adjusted depending on the resources available on the host computer.

### Configure the Hostname

Add the following entry to `/etc/hosts` so that the domain can be accessed from the local browser:

```bash
sudo nano /etc/hosts
```

Add:

```text
127.0.0.1    mmatsui.42.fr
```

### Configure the Privileged Port

If required by the Virtual Machine environment, configure the system to allow non-root processes to bind to ports from `443`:

```bash
sudo sysctl net.ipv4.ip_unprivileged_port_start=443
```

To make it permanent, you write the setting into a config file that Linux reads and applies automatically at every boot. The standard location for custom sysctl settings is a file under /etc/sysctl.d/:
```bash
sudo nano /etc/sysctl.d/99-unprivileged-ports.conf
```
Add:

```text
net.ipv4.ip_unprivileged_port_start=443
```
Save and exit the same way as before (Ctrl+O, Enter, Ctrl+X).

To verify it'll actually apply without even rebooting:
```bash
sudo sysctl --system
```


## Makefile

The Makefile provides commands to simplify the management of the Docker environment.

### Set Up Secrets

```bash
make setup
```

This command:

* Creates the `secrets` directory.
* Generates random passwords.
* Stores each password in a separate text file:

  * `db_root_password.txt`
  * `db_password.txt`
  * `wp_admin_password.txt`

The secret files are used by Docker Compose to provide sensitive credentials to the appropriate containers.

### Start the Containers

```bash
make up
```

This is equivalent to:

```bash
docker compose -f $(COMPOSE_FILE) up
```

This command starts the containers using the existing Docker images.

If the images have not been built yet, Docker Compose may report that the required images are missing. Use `make build` to build the images and start the containers.

If the containers and volumes already exist, the existing data is preserved.

### Build Images and Start the Containers

```bash
make build
```

This command first runs:

```bash
make setup
```

and then:

```bash
docker compose -f $(COMPOSE_FILE) up --build
```

`--build` tells Docker Compose to build the images before starting the containers.

Use this command when you have changed a Dockerfile or other files used during the image build and want to rebuild the images.

A Docker **image** is a blueprint containing the software, configuration, and dependencies required to create a container.

A Docker **container** is a running instance of an image.

### Stop the Containers

```bash
make down
```

This is equivalent to:

```bash
docker compose -f $(COMPOSE_FILE) down
```

This command stops and removes the project's containers and networks, but does not remove the named volumes.

The data stored in the volumes is therefore preserved.

When you run `make up` again, the containers can use the existing volumes and their data remains available.

### Stop Containers and Remove Volumes

```bash
make fdown
```

This is equivalent to:

```bash
docker compose -f $(COMPOSE_FILE) down -v
```

and removing the local `secrets` directory.

The `-v` option removes the Docker volumes associated with the project, so persistent data such as the MariaDB database and WordPress data is deleted.

The secrets directory is also removed so that the generated password files are deleted.

**Warning:** This command permanently removes the project's persistent data and generated secret files.

### Clean Rebuild

```bash
make re
```

This is a combination of:

```bash
make fdown
make build
```

It removes the existing containers, networks, volumes, and generated secrets, then creates new secrets, rebuilds the Docker images, and starts new containers.

Use this command when you want to completely reset the project and start with a fresh environment.

## Container Management and Debugging

### Check Container Status

To check whether all containers are running:

```bash
docker compose ps
```

For example:

```text
NAME             SERVICE     STATUS
mariadb          mariadb     running
wordpress        wordpress   running
nginx            nginx       running
adminer          adminer     running
```

You can also use:

```bash
docker ps
```

to display all currently running Docker containers.

### Access a Running Container

To execute a command inside a running container, use:

```bash
docker compose exec <service> <command>
```

For example:

```bash
docker compose exec mariadb bash
```

If `bash` is not available:

```bash
docker compose exec mariadb sh
```

The same can be used for the other services:

```bash
docker compose exec wordpress bash
docker compose exec nginx bash
docker compose exec adminer sh
```

### Check Container Logs

To check the logs of a specific service:

```bash
docker compose logs <service>
```

For example:

```bash
docker compose logs mariadb
docker compose logs wordpress
docker compose logs nginx
docker compose logs adminer
```

To follow the logs in real time:

```bash
docker compose logs -f nginx
```

### Check Processes Inside a Container

To display the processes running inside a specific container:

```bash
docker compose top <service>
```

For example:

```bash
docker compose top mariadb
docker compose top wordpress
docker compose top nginx
docker compose top adminer
```

These commands are useful for checking the status of containers and troubleshooting problems without directly modifying the containers.

*docker compose exec only works with a running container. If a container has stopped, use docker compose ps and docker compose logs <service> first to find out why.


## Data Storage and Persistence

The project uses Docker named volumes to store data outside the containers' writable layers.

The volumes are defined in `docker-compose.yml`:

```yaml
volumes:
  mariadb_data:
  wordpress_data:
  adminer_data:
```

Docker manages the physical storage location of these volumes on the host system.

### MariaDB Data

The `mariadb_data` volume is mounted inside the MariaDB container:

```yaml
mariadb:
  volumes:
    - mariadb_data:/var/lib/mysql
```

MariaDB stores its database files in:

```text
/var/lib/mysql
```

Because this directory is mounted to the `mariadb_data` volume, the database data persists even when the MariaDB container is removed and recreated.

```text
MariaDB container
       │
       ▼
/var/lib/mysql
       │
       ▼
mariadb_data
       │
       ▼
Persistent Docker volume
```

### WordPress Data

The `wordpress_data` volume is shared between the WordPress and NGINX containers.

```yaml
wordpress:
  volumes:
    - wordpress_data:/var/www/html

nginx:
  volumes:
    - wordpress_data:/var/www/html:ro
```

WordPress writes its files to:

```text
/var/www/html
```

NGINX mounts the same volume as read-only using `:ro`. This allows NGINX to access the WordPress files without modifying them.

```text
WordPress
    │
    │ read/write
    ▼
wordpress_data
    │
    ├──────────► Persistent Docker volume
    │
    ▼
NGINX
read-only
```

As a result, WordPress files persist when the WordPress container is recreated.

### Adminer Data

The `adminer_data` volume is used to share the Adminer files between the Adminer and NGINX containers.

```yaml
adminer:
  volumes:
    - adminer_data:/var/www/adminer

nginx:
  volumes:
    - adminer_data:/var/www/adminer
```

The Adminer container stores the Adminer application files in:

```text
/var/www/adminer
```

The NGINX container mounts the same volume so that it can serve the Adminer web interface.

### How Data Persists

Docker volumes exist independently from containers.

For example:

```text
Container
    │
    ▼
Mounted directory
    │
    ▼
Docker named volume
    │
    ▼
Docker-managed storage on the host
```

When running:

```bash
make down
```

Docker Compose stops and removes the containers, but the named volumes remain. When the project is started again, the new containers reuse the existing volumes.

Therefore, the MariaDB database and WordPress files remain available.

To completely remove the containers and volumes, run:

```bash
make fdown
```

This runs:

```bash
docker compose -f $(COMPOSE_FILE) down -v
```

The `-v` option removes the project's named volumes:

* `mariadb_data`
* `wordpress_data`
* `adminer_data`

As a result, the MariaDB database, WordPress files, and Adminer files stored in these volumes are removed. The project will start with a fresh environment the next time it is rebuilt.
