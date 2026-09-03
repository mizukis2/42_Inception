# User Documentaiton
This project provides two web services through the same domain using different HTTPS ports.

## Services

- WordPress: https://mmatsui.42.fr
- WordPress Administration Panel: https://mmatsui.42.fr/wp-admin
- Adminer: https://mmatsui.42.fr:8080

## Starting the project

```bash
make build
```

### WordPress

Open a web browser and go to:

```text
https://mmatsui.42.fr:443
```

Port `443` is the standard HTTPS port, so `:443` can also be omitted:

```text
https://mmatsui.42.fr
```

This will display the WordPress website.

#### Blog

From the WordPress website, you can visit the blog page and leave a comment.

Comments submitted by visitors require administrator approval before they are displayed publicly.

### WordPress Administration Panel

The WordPress administration panel can be accessed at:

```text
https://mmatsui.42.fr/wp-admin
```

To log in, you need the administrator email address and password.

The administrator email address can be found in the `.env` file:

```bash
cat srcs/.env
```

For example:

```text
WP_ADMIN_EMAIL=wp_admin@email.com
```

The administrator password is stored in the secrets directory:

```bash
cat secrets/wp_admin_password.txt
```

You can copy these credentials and use them to log in to the WordPress administration panel.

From the administration panel, you can, for example:

* Approve or delete comments
* Manage posts and pages
* Manage WordPress users
* Change website settings

### Adminer

Adminer can be accessed using port `8080`:

```text
https://mmatsui.42.fr:8080
```

This opens the Adminer web interface, which can be used to manage the MariaDB database.

#### Adminer Login

Use the following information to log in:

| Field    | Value                         |
| -------- | ----------------------------- |
| System   | `MySQL`                       |
| Server   | `mariadb`                     |
| Username | Value of `MYSQL_USER`         |
| Password | Contents of `db_password.txt` |
| Database | Value of `MYSQL_DATABASE`     |

The username and database name can be found in the `.env` file:

```bash
cat srcs/.env
```

The database password is stored in the secrets directory:

```bash
cat secrets/db_password.txt
```

Copy the required values into the corresponding fields in the Adminer login page.

### TLS Certificate Warning

Because this project uses a self-signed TLS certificate, the browser may display a security warning such as:

> Warning: Potential Security Risk Ahead

This is expected for the local development environment.

Click **Advanced...** and then **Accept the Risk and Continue** to access the website.


## Stop the project

```bash
make down
```

## Manage credentials

```bash
secrets/
├── db_password
├── db_root_password
└── wp_admin_password
```
- `db_root_password.txt` → MariaDB root password
- `db_password.txt` → MariaDB application user password
- `wp_admin_password.txt` → WordPress administrator password
- Secrets are generated automatically by `make setup` if they don't already exist.
- They should not be committed to Git.
- Running `make down` keeps the existing credentials.
- Running `make fclean` removes the secrets, so the next build generates new credentials.
- These passwords can be retrieved by running
```bash
cat secrets/db_password.txt
cat secrets/db_root_password.txt
cat secrets/wp_admin_password.txt
```

## Basic check
### Check running containers
```bash
docker compose -f srcs/docker-compose.yml ps
```
### Check Docker network
```bash
docker network ls
```
### Check volumes
```bash
docker volume ls
```
### Check persistent storage
```bash
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```