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

## Make directories for data
``` bash
mkdir -p /home/mmatsui/data/mariadb
mkdir -p /home/mmatsui/data/wordpress
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

The project uses Docker named volumes to store persistent data outside the containers' writable layers.

The volumes are defined in `docker-compose.yml`:

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mmatsui/data/mariadb

  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/mmatsui/data/wordpress

  adminer_data:
```

The `mariadb_data` and `wordpress_data` volumes use the Docker `local` volume driver with bind-mount options. This means that the actual data is stored in directories on the VM:

```text
/home/mmatsui/data/mariadb
/home/mmatsui/data/wordpress
```

The containers access these directories through Docker named volumes.

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

This is the MariaDB data directory **inside the container**.

The named volume is backed by the following directory on the VM:

```text
/home/mmatsui/data/mariadb
```

Therefore, the data flow is:

```text
VM host
/home/mmatsui/data/mariadb
        │
        │ bind mount
        ▼
mariadb_data
Docker named volume
        │
        ▼
MariaDB container
/var/lib/mysql
        │
        ▼
MariaDB database files
```

Because the database files are stored outside the container's writable layer, the data remains available when the MariaDB container is removed and recreated, as long as the volume and its backing directory are preserved.

### WordPress Data

The `wordpress_data` volume is shared between the WordPress and NGINX containers:

```yaml
wordpress:
  volumes:
    - wordpress_data:/var/www/html

nginx:
  volumes:
    - wordpress_data:/var/www/html:ro
```

WordPress stores its files in:

```text
/var/www/html
```

The `wordpress_data` volume is backed by the following directory on the VM:

```text
/home/mmatsui/data/wordpress
```

WordPress mounts the volume with read/write access, while NGINX mounts the same volume as read-only using `:ro`.

This allows:

* WordPress to create and modify files.
* NGINX to read and serve those files.
* NGINX to be prevented from modifying the WordPress files through this mount.

The data flow is:

```text
VM host
/home/mmatsui/data/wordpress
        │
        │ bind mount
        ▼
wordpress_data
Docker named volume
        │
        ├──────────────► WordPress
        │                /var/www/html
        │                read/write
        │
        └──────────────► NGINX
                         /var/www/html
                         read-only
```

As a result, WordPress files persist independently of the WordPress container.

### Adminer Data

The `adminer_data` volume is used to share the Adminer application files between the Adminer and NGINX containers:

```yaml
adminer:
  volumes:
    - adminer_data:/var/www/adminer

nginx:
  volumes:
    - adminer_data:/var/www/adminer
```

The Adminer application files are stored inside the Adminer container at:

```text
/var/www/adminer
```

The same volume is mounted by NGINX so that NGINX can access the Adminer files required to serve the Adminer web interface.

Unlike `mariadb_data` and `wordpress_data`, `adminer_data` does not contain the application's database data. It is used to share the Adminer application files between the two containers.

### How Data Persists

Docker named volumes have a lifecycle independent from the containers that use them.

In this project, MariaDB and WordPress use named volumes backed by directories on the VM:

```text
MariaDB

/home/mmatsui/data/mariadb
        │
        ▼
mariadb_data
        │
        ▼
/var/lib/mysql
        │
        ▼
MariaDB
```

```text
WordPress

/home/mmatsui/data/wordpress
        │
        ▼
wordpress_data
        │
        ├──────────► /var/www/html (WordPress, read/write)
        │
        └──────────► /var/www/html (NGINX, read-only)
```

This separation means that the containers themselves can be removed and recreated without losing the persistent MariaDB database or WordPress files.

However, removing the volumes themselves, or deleting their backing directories on the VM, will remove the persistent data.


### Removing Containers and Volumes

When running:

```bash
make down
```

Docker Compose stops and removes the containers, but the named volumes remain.

When the project is started again, the new containers reuse the existing volumes. Therefore, the MariaDB database, WordPress files, and Adminer files remain available.

To remove the containers and Docker named volumes, run:

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

However, `mariadb_data` and `wordpress_data` are backed by directories on the VM:

```text
/home/mmatsui/data/mariadb
/home/mmatsui/data/wordpress
```

Therefore, `make fdown` removes the Docker named volumes but **does not delete the data stored in these directories**.

The Adminer volume is a Docker-managed volume, so its contents are removed when `adminer_data` is removed.

To completely reset the project, including the persistent MariaDB and WordPress data, the backing directories must also be deleted manually:

```bash
sudo rm -rf /home/mmatsui/data/mariadb
sudo rm -rf /home/mmatsui/data/wordpress
```

After deleting these directories, the project will start with a fresh MariaDB database and WordPress installation the next time it is rebuilt.
