# Project Description

This project utilizes Fluent Bit, Grafana, and Loki to set up logging in a Kubernetes (K8s) environment. The goal is to visualize logs and simplify the debugging process. Currently, KIND is used to set up a local K8s cluster, but Minikube is also supported.

- **Fluent Bit**: A lightweight log processor and forwarder.
- **Grafana**: An open-source platform for monitoring and observability.
- **Loki**: A log aggregation system designed to store and query logs.

By integrating these tools, we aim to create an efficient and user-friendly logging solution for Kubernetes environments.

## Getting Started

To run this project, follow these steps:

1. **Install Prerequisites**:
    - **Docker**: [Install Docker](https://docs.docker.com/get-docker/)
    - **Helm**: [Install Helm](https://helm.sh/docs/intro/install/)
    - **KIND**: [Install KIND](https://kind.sigs.k8s.io/docs/user/quick-start/)

2. **Run the Setup Script**:
    - Navigate to the `run_script` directory.
    - Execute the setup script:
    
      cd run_script
      ./run.sh
      
This will set up the local Kubernetes cluster and deploy Fluent Bit, Grafana, and Loki.

DEMO URL
https://www.youtube.com/watch?v=bf6ZtD-97tk
