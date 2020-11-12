Terraform Module: Internal Load Balancer (Container)
----------------------------------------------------

A Terraform module for [Google Cloud Platform](https://cloud.google.com/) that makes it easy to start up a Docker image
behind an internal TCP/UDP load balancer.

When applied, this module will create an internal TCP load balancer, as well as a regional managed instance group having
all the required health checks to ensure instances are automatically healed. 

## Usage

```hcl-terraform
// Minimal usage
module my_lb {
  source = "garbetjie/internal-lb-container/google"
  region = "europe-west1"
  image = "nginx:latest"
  ports = [
    { protocol = "udp", port = 8080 },
    { protocol = "tcp", port = 8080 }
  ]
}
```

## Inputs

| Name                   | Description                                                                       | Type                                           | Default                                                  | Required |
|------------------------|-----------------------------------------------------------------------------------|------------------------------------------------|----------------------------------------------------------|----------|
| region                 | Name of the region in which to create resources.                                  | string                                         |                                                          | Yes      |
| image                  | Docker image to run.                                                              | string                                         |                                                          | Yes      |
| ports                  | Ports to expose from the container.                                               | list(object({ protocol=string, port=number })) |                                                          | Yes      |
| name_prefix            | Prefix to give to the names of all created resources. Trailing `-`'s are removed. | string                                         | `"i-lb-c-${random_id.default_prefix.hex}-${var.region}"` | No       |
| env                    | Environment variables to inject into the running container.                       | map(string)                                    | `{}`                                                     | No       |
| machine_type           | GCE instance type to run the container on.                                        | string                                         | `f1-micro`                                               | No       |
| disk_type              | Disk type to create the GCE instances with.                                       | string                                         | `pd-standard`                                            | No       |
| disk_size              | Disk size to create the GCE instances with.                                       | number                                         | `15`                                                     | No       |
| tags                   | Network to add to the GCE instances.                                              | list(string)                                   | `[]`                                                     | No       |
| labels                 | Labels to apply to all created resources.                                         | map(string)                                    | `{}`                                                     | No       |
| service_account_email  | Service account to run instances with.                                            | string                                         | `null`                                                   | No       |
| service_account_scopes | Scopes to run service account with.                                               | list(string)                                   | `[]`                                                     | No       |
| replicas               | Number of instances to ensure are running.                                        | number                                         | `1`                                                      | No       |
| allow_global_access    | Allow traffic to the load balancer from other regions.                            | bool                                           | `true`                                                   | No       |
| all_ports              | Expose all ports on the load balancer, rather than just the specified ones.       | bool                                           | `true`                                                   | No       |
| volumes                | Volumes to mount into the container.                                              | map(string)                                    | `{}`                                                     | No       |
| always_pull            | Always pull the image before running it.                                          | bool                                           | `false`                                                  | No       |

## Outputs

| Name                  | Description                                       |
|-----------------------|---------------------------------------------------|
| address               | Address of the load balancer.                     |
| ports                 | Ports supplied as an input variable.              |
| labels                | Labels supplied as input variable.                |
| service_account_email | Service account email supplied as input variable. |
| tcp_ports             | List of TCP ports exposed.                        |
| udp_ports             | List of UDP ports exposed.                        |
