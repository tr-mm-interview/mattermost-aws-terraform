# Mattermost AWS Terraform

Terraform for an interview/demo Mattermost deployment on AWS.

## Architecture

This repository builds the AWS infrastructure for a single-host Docker deployment managed by Ansible:

```text
Internet client
  HTTPS 443
Public AWS Network Load Balancer
  TLS listener 443, ACM certificate
TLS target group 443
EC2 Docker host
  Nginx container on host port 443
  Mattermost container on Docker network port 8065
  Postgres container on internal Docker network
  OpenLDAP container on internal Docker network
EFS
  Mounted on the Docker host for shared persistent application data
AWS Secrets Manager
  Secret containers only; values are populated out of band
S3
  Dedicated bucket for Ansible SSM connection module transfer
```

Only the NLB is internet-facing. The Docker host security group accepts inbound `443` only from the NLB security group. Mattermost, Postgres and OpenLDAP are not exposed directly to the public internet.

SSH is not required or opened. Ansible connects to the EC2 instance through AWS Systems Manager Session Manager and uses the dedicated Ansible SSM S3 bucket for module transfer.

Terraform also creates an `ansible_deployer_policy_arn` output for local or GitHub Actions deploy identities. To attach it automatically, set `ansible_deploy_role_names` to the IAM role names that run Ansible.

TLS is used from client to NLB and from NLB to Nginx on the host:

```text
Client HTTPS -> NLB TLS listener -> TLS target group -> EC2/Nginx:443
```

## First Boot Bootstrap

The EC2 Docker host uses intentionally minimal cloud-init user data from `scripts/ubuntu_bootstrap_v01`. It updates the OS, installs Python for Ansible, installs the NFS client, mounts EFS at `efs_mount_path`, ensures the SSM agent is running if the AMI provides it, and creates `/opt/mattermost`.

Cloud-init does not install the application stack, render `docker-compose.yml`, render `nginx.conf`, pull application secrets, or start Mattermost. Ansible owns Docker installation, application configuration and deployment after the host is reachable.

## Persistent Storage

Terraform creates an encrypted EFS file system for shared Docker application data and mount targets in the existing public subnets. The EFS security group only allows NFS on port `2049` from the Docker host security group.

Cloud-init installs `nfs-common` and mounts EFS at `efs_mount_path`, which defaults to `/mnt/docker-data`. `/opt/mattermost` remains the application working directory; Ansible should create service-specific data directories on the mounted shared storage path.

## TLS Certificate

The public NLB TLS listener needs an ACM certificate in the same AWS region as the NLB. By default, Terraform requests a certificate for `mattermost_hostname`, creates the DNS validation record in `route53_zone_name`, waits for validation, and attaches the issued certificate to the listener.

To use an existing certificate instead, set:

```hcl
acm_certificate_arn = "arn:aws:acm:eu-west-2:123456789012:certificate/..."
```

## Populating Secrets Manager values

Terraform creates the Secrets Manager secret containers and outputs their ARNs, but it does not commit or manage plaintext secret values. Populate the values manually after `terraform apply`.

Run these commands from `infra/` after the secret containers exist:

```bash
export AWS_PROFILE=Tom
export AWS_REGION=eu-west-2

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw mattermost_db_password_secret_arn)" \
  --secret-string "$(openssl rand -base64 32)"

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw postgres_admin_password_secret_arn)" \
  --secret-string "$(openssl rand -base64 32)"

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw mattermost_site_secret_arn)" \
  --secret-string "$(openssl rand -base64 48)"

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw openldap_admin_password_secret_arn)" \
  --secret-string "$(openssl rand -base64 32)"

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw openldap_bind_password_secret_arn)" \
  --secret-string "$(openssl rand -base64 32)"
```

For the backend TLS certificate used by Nginx behind the NLB, generate or provide a certificate/key pair, then store the PEM content in the two Nginx secrets:

```bash
openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
  -keyout nginx-backend.key \
  -out nginx-backend.crt \
  -subj "/CN=mattermost-backend.local"

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw nginx_backend_tls_certificate_secret_arn)" \
  --secret-string file://nginx-backend.crt

aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw nginx_backend_tls_private_key_secret_arn)" \
  --secret-string file://nginx-backend.key
```

Mattermost Team Edition does not require a license for the first deployment. If a license is needed later, set `create_mattermost_license_secret = true`, apply Terraform, then populate it:

```bash
aws secretsmanager put-secret-value \
  --secret-id "$(terraform output -raw mattermost_license_secret_arn)" \
  --secret-string file://mattermost-license.txt
```

Do not commit generated secret files, `.env` files, or command output containing secret values.
