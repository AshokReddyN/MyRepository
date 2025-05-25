# Spring Boot User Management with OTP & AWS ECS Deployment

## Objective

This project implements a User Management service using Spring Boot, enabling user registration and login via mobile number and One-Time Passwords (OTPs). The application is designed for cloud deployment on AWS ECS Fargate, with infrastructure managed by Terraform and CI/CD automated through GitHub Actions.

## Tech Stack

*   **Backend:** Spring Boot (Java 11), Spring Security, Spring Data MongoDB
*   **Database:** MongoDB
*   **OTP Service:** Fast2SMS (current implementation uses placeholders and logs OTPs)
*   **Authentication:** JWT (JSON Web Tokens) for session management after OTP verification
*   **Containerization:** Docker
*   **Infrastructure as Code (IaC):** Terraform
*   **Cloud Provider:** Amazon Web Services (AWS)
    *   **Compute:** Elastic Container Service (ECS) with Fargate
    *   **Networking:** Virtual Private Cloud (VPC), Application Load Balancer (ALB)
    *   **Container Registry:** Elastic Container Registry (ECR)
    *   **Identity & Access Management:** IAM
    *   **Logging:** CloudWatch Logs
*   **CI/CD:** GitHub Actions
*   **Build Tool:** Apache Maven

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy-dev.yml      # GitHub Actions workflow for dev deployment
├── api/                        # Spring Boot application source code
│   ├── src/
│   ├── pom.xml
│   └── Dockerfile              # Dockerfile for the Spring Boot application
├── infra/                      # Terraform infrastructure code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── versions.tf
│   └── modules/                # Reusable Terraform modules (vpc, ecr, ecs, alb, iam)
│       ├── alb/
│       ├── ecr/
│       ├── ecs/
│       ├── iam/
│       └── vpc/
└── README.md                   # This file
```

*   **`api/`**: Contains the Spring Boot application responsible for user registration, OTP generation/validation, login, and JWT management.
*   **`infra/`**: Holds all Terraform code to define and provision the AWS infrastructure, including VPC, subnets, NAT Gateways, ECR, ECS cluster, Fargate service, Application Load Balancer, and necessary IAM roles and security groups.
*   **`.github/workflows/`**: Includes GitHub Actions workflows for Continuous Integration and Continuous Deployment (CI/CD), automating the build, test, Docker image push, and infrastructure deployment.

## Prerequisites

To build, run, and deploy this project, you will generally need:

*   **Docker Desktop:** (or Docker Engine + Docker Compose CLI) For building and running the application in containers. This is the primary method for local execution if you don't want to manage Java/Maven on your host.
*   **Terraform CLI:** (Version >= 1.0) For managing AWS infrastructure.
*   **AWS CLI:** For interacting with your AWS account.
*   **Active AWS Account:** With appropriate permissions to create the resources defined in the Terraform scripts (VPC, ECS, ECR, ALB, IAM roles, etc.).
*   **MongoDB Instance:** Access to a MongoDB database (local or cloud-hosted like MongoDB Atlas) is required for the application to function. The Docker Compose setup includes a MongoDB container.
*   **(Optional) Fast2SMS Account:** A Fast2SMS account and API key if you intend to enable actual SMS OTP delivery.

**For local native development/builds (running the Spring Boot app directly on your host without Docker):**
*   **Java JDK 11:** Or a compatible version as specified in `api/pom.xml`.
*   **Apache Maven:** For building and running the Spring Boot application natively.

## Local Development (`api/` service)

This section describes running the Spring Boot application directly on your host machine (native execution). **For this method, Java JDK 11 and Maven are required.** If you prefer a containerized setup using Docker, see the "Running Locally with Docker Compose" section.

### Configuration

The Spring Boot application requires several configuration properties, primarily for connecting to MongoDB, JWT signing, and the Fast2SMS service. These are managed in `api/src/main/resources/application.properties`.

You can override these properties using:
1.  Profile-specific properties files (e.g., `application-dev.properties`, `application-qa.properties`). The default active profile is `dev`.
2.  Environment variables.

**Key properties to configure for local development (e.g., in `application-dev.properties` or via environment variables):**

*   **MongoDB URI:**
    ```properties
    spring.data.mongodb.uri=mongodb://localhost:27017/user_management_dev
    ```
*   **JWT Secret:**
    ```properties
    jwt.secret=yourStrongLocalJwtSecretKey2024! # Choose a strong, unique secret
    ```
*   **Fast2SMS (currently logs OTPs):**
    ```properties
    fast2sms.api.key=yourFast2SmsApiKey # Provide your key if testing actual SMS
    fast2sms.api.url=https://www.fast2sms.com/dev/bulkV2 # Confirm the correct API URL
    ```
    (Note: The current `OtpService.java` logs OTPs to the console. See "Fast2SMS Integration Note" for enabling actual SMS.)

### Building

Navigate to the `api` directory and use Maven to build the application:
```bash
cd api
mvn clean package
```
This will compile the code, run tests, and create a JAR file in the `api/target/` directory (e.g., `user-management-0.0.1-SNAPSHOT.jar`).

### Running

You can run the application using Maven or by executing the JAR file:

*   **Using Maven:**
    ```bash
    cd api
    mvn spring-boot:run
    ```
*   **Using the JAR file:**
    ```bash
    cd api
    java -jar target/user-management-0.0.1-SNAPSHOT.jar
    ```
The application will typically start on port `8080`.

### Testing & API Documentation

Once the application is running locally, you can access the Swagger UI for API documentation and testing:
*   **Swagger UI:** `http://localhost:8080/swagger-ui.html`

## Running Locally with Docker Compose

This section describes how to run the User Management API and its MongoDB dependency using Docker Compose for a containerized local development environment.

### Prerequisites

*   **Docker Desktop:** Installed and running. Alternatively, Docker Engine with Docker Compose CLI. Ensure the Docker daemon is active. **No local Java or Maven installation is required for this method** as the application will be built inside a Docker container using the multi-stage `api/Dockerfile`.

### Configuration (Optional but Recommended)

Before starting, it's highly recommended to update the default JWT secret for better security, even for local development.

1.  **Open `docker-compose.yml`:** Locate this file at the root of the project.
2.  **Update `JWT_SECRET`:**
    Find the `environment` section for the `user-management-api` service and change the `JWT_SECRET` value:
    ```yaml
    services:
      user-management-api:
        environment:
          # ... other environment variables
          - JWT_SECRET=YourStrongSecretForDockerComposeEnvironmentPleaseChange # <-- CHANGE THIS
          # ... other environment variables
    ```
    Replace `YourStrongSecretForDockerComposeEnvironmentPleaseChange` with a strong, unique secret.

### Commands

Navigate to the root directory of the project where `docker-compose.yml` is located before running these commands.

*   **Build and Start Services:**
    This command will:
    1.  Build the Docker image for the Spring Boot application using the multi-stage `api/Dockerfile`. This process includes compiling the Java code and packaging the JAR **inside a Docker container**, so you do **not** need Java or Maven installed on your host machine for this method.
    2.  Start both the `user-management-api` and `mongodb` services.

    ```bash
    docker-compose up --build
    ```
    To run the services in detached mode (in the background):
    ```bash
    docker-compose up --build -d
    ```

*   **Accessing the Application:**
    Once the services are up and running:
    *   **Application API:** `http://localhost:8080`
    *   **Swagger UI for API testing:** `http://localhost:8080/swagger-ui.html`

*   **Viewing Logs:**
    To view the logs from the running containers (especially useful for seeing the OTPs):
    *   For the User Management API:
        ```bash
        docker-compose logs -f user-management-api
        ```
    *   For MongoDB:
        ```bash
        docker-compose logs -f mongodb
        ```
    Press `Ctrl+C` to stop tailing the logs.

*   **Stopping Services:**
    To stop and remove the containers, network, and (optionally) volumes:
    ```bash
    docker-compose down
    ```

*   **Data Persistence:**
    *   MongoDB data is persisted in a Docker named volume called `mongodb_data` (as defined in `docker-compose.yml`). This means your data will remain even if you stop and remove the containers with `docker-compose down`.
    *   To stop the services and remove the `mongodb_data` volume (e.g., to start fresh), use:
        ```bash
        docker-compose down -v
        ```

### How OTP Works with Docker Compose

When running via Docker Compose:
*   **OTPs are logged to the console** of the `user-management-api` container.
*   You can view these logs to get the OTP for registration or login using the command:
    ```bash
    docker-compose logs -f user-management-api
    ```
    Look for log entries similar to: `SIMULATING SMS: Sending OTP 123456 to mobile number ...`

## Infrastructure Deployment (`infra/`)

The AWS infrastructure is managed using Terraform.

### Configuration

1.  **Navigate to the `infra` directory:**
    ```bash
    cd infra
    ```
2.  **Configure Variables:**
    Terraform variables are defined in `infra/variables.tf`. You can customize these by:
    *   Creating a `terraform.tfvars` file (e.g., `dev.tfvars` for a specific environment). **This method is suitable for non-sensitive variables.**
    *   Setting environment variables prefixed with `TF_VAR_` (e.g., `export TF_VAR_aws_region="us-west-2"`). **This method is recommended for passing sensitive data during local `terraform apply` runs, as environment variables are less likely to be accidentally committed.**

    **Example `dev.tfvars` structure (for non-sensitive overrides):**
    ```tfvars
    aws_region = "us-east-1"
    env_name   = "dev"
    vpc_cidr   = "10.0.0.0/16"
    # Add other non-sensitive variables you wish to override from defaults.
    ```

    **For sensitive data (like database URIs, API keys, JWT secrets):**
    It is strongly recommended to pass these as environment variables when running `terraform apply` locally, or use a secure secrets management solution for automated CI/CD pipelines. The GitHub Actions workflow demonstrates passing secrets from GitHub Secrets.

    **Example for local `terraform apply` using environment variables for secrets:**
    ```bash
    export TF_VAR_mongodb_uri_placeholder="mongodb://your-dev-mongo-uri-from-env"
    export TF_VAR_jwt_secret_placeholder="yourDevJwtSecretFromEnv"
    export TF_VAR_fast2sms_api_key_placeholder="yourDevFast2SmsKeyFromEnv"
    # Then run: terraform plan or terraform apply
    ```
    The `_placeholder` suffix in `variables.tf` indicates these are intended to be overridden.

### Deployment Steps

1.  **Initialize Terraform:**
    Downloads necessary provider plugins.
    ```bash
    cd infra
    terraform init
    ```
2.  **Validate Configuration:**
    Checks if the configuration is syntactically valid.
    ```bash
    terraform validate
    ```
3.  **Plan Deployment:**
    Creates an execution plan, showing what Terraform will do.
    ```bash
    # Option 1: Using .tfvars file (ensure secrets are not in this file or are handled securely)
    # terraform plan -var-file="dev.tfvars"

    # Option 2: Relying on TF_VAR_ environment variables (especially for secrets)
    terraform plan
    ```
4.  **Apply Deployment:**
    Provisions the infrastructure on AWS.
    ```bash
    # Option 1: Using .tfvars file
    # terraform apply -var-file="dev.tfvars" -auto-approve

    # Option 2: Relying on TF_VAR_ environment variables
    terraform apply -auto-approve
    ```
    The `-auto-approve` flag skips interactive approval; use with caution, especially in production.

### Key Outputs

After a successful `terraform apply`, note the following outputs (defined in `infra/outputs.tf`):
*   `alb_dns_name`: The DNS name of the Application Load Balancer to access the deployed service.
*   `ecr_repository_url`: The URL of the ECR repository where Docker images are stored.
*   `ecs_cluster_name`: Name of the created ECS cluster.
*   `ecs_service_name`: Name of the created ECS service.

## CI/CD Automation (`.github/workflows/deploy-dev.yml`)

The project includes a GitHub Actions workflow defined in `.github/workflows/deploy-dev.yml` to automate the deployment process for the `dev` environment.

*   **Purpose:** The workflow automates:
    1.  Building and testing the Spring Boot application.
    2.  Building a Docker image of the application.
    3.  Pushing the Docker image to Amazon ECR.
    4.  Running `terraform apply` to deploy the new image to AWS ECS Fargate by updating the ECS Task Definition and Service.
*   **Trigger:**
    *   On push to the `develop` branch.
    *   Manual trigger via `workflow_dispatch`.
*   **Required GitHub Secrets:**
    The workflow requires the following secrets to be configured in your GitHub repository settings (`Settings > Secrets and variables > Actions`):
    *   `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
    *   `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
    *   `MONGODB_URI_DEV`: MongoDB connection URI for the dev environment (corresponds to `TF_VAR_mongodb_uri_placeholder`).
    *   `JWT_SECRET_DEV`: JWT secret key for the dev environment (corresponds to `TF_VAR_jwt_secret_placeholder`).
    *   `FAST2SMS_API_KEY_DEV`: Fast2SMS API key for the dev environment (corresponds to `TF_VAR_fast2sms_api_key_placeholder`).
    *   `FAST2SMS_API_URL_DEV`: Fast2SMS API URL for the dev environment (corresponds to `TF_VAR_fast2sms_api_url_placeholder`).

## API Endpoints

Once the application is deployed, API endpoints can be accessed via the Application Load Balancer's DNS name. The Swagger UI provides a comprehensive list and allows interaction with the APIs.

*   **Swagger UI (once deployed):** `http://<ALB_DNS_NAME>/swagger-ui.html` (replace `<ALB_DNS_NAME>` with the output from `terraform output alb_dns_name`).

**Primary Endpoints:**

*   **User Registration:**
    *   `POST /api/auth/register/send-otp`: Sends an OTP to the provided mobile number for registration.
    *   `POST /api/auth/register/verify-otp`: Verifies the OTP and completes user registration.
*   **User Login:**
    *   `POST /api/auth/login/send-otp`: Sends an OTP to the provided mobile number for login.
    *   `POST /api/auth/login/verify-otp`: Verifies the OTP and returns a JWT token for successful login.
*   **Resend OTP:**
    *   `POST /api/auth/resend-otp`: Resends an OTP to the provided mobile number.
*   **Protected Endpoint Example:**
    *   `GET /api/users/me`: Fetches details of the currently authenticated user (requires JWT Bearer token).

## Fast2SMS Integration Note

The current implementation of `OtpService.java` in the `api/` module **logs the OTP to the console** for development and testing purposes. It does not make an actual HTTP call to the Fast2SMS API.

To enable actual SMS sending:

1.  **Provide a Valid API Key:** Ensure the `fast2sms.api.key` property (or corresponding environment variable `FAST2SMS_API_KEY` for ECS tasks, passed as `TF_VAR_fast2sms_api_key_placeholder` to Terraform) is set with your valid Fast2SMS API key.
2.  **Update `OtpService.java`:**
    Locate the `sendOtpViaSms` method in `api/src/main/java/com/example/usermanagement/service/OtpService.java`.
    Uncomment or implement the HTTP client logic to call the Fast2SMS API.

    **Example structure (you might use `RestTemplate`, `WebClient`, or another HTTP client):**
    ```java
    // Inside OtpService.java, method sendOtpViaSms(String mobileNumber, String otpCode)

    // TODO: Implement actual Fast2SMS API call here
    // Example using RestTemplate (ensure RestTemplate is available or use WebClient):
    /*
    // Ensure RestTemplate is properly configured (e.g., as a bean)
    // RestTemplate restTemplate = new RestTemplate();
    HttpHeaders headers = new HttpHeaders();
    headers.set("authorization", fast2SmsApiKey);
    // Fast2SMS often uses application/x-www-form-urlencoded or application/json
    headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED); 

    MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
    // These parameter names are examples; refer to Fast2SMS V2 documentation
    map.add("variables_values", otpCode); 
    map.add("route", "otp"); // Or "dlt", "q", "v3" depending on your Fast2SMS setup & API version
    map.add("numbers", mobileNumber);
    // map.add("sender_id", "FSTSMS"); // If required by your Fast2SMS setup
    // map.add("message", "YOUR_MESSAGE_TEMPLATE_ID_IF_USING_DLT"); // For DLT templates
    // map.add("language", "english"); // If applicable

    HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);

    try {
        // ResponseEntity<String> response = restTemplate.postForEntity(fast2SmsApiUrl, request, String.class);
        // logger.info("Fast2SMS response for {}: {}", mobileNumber, response.getBody());
        // // Add logic here to check if response.getBody() indicates success, e.g.,
        // // if (response.getStatusCode() == HttpStatus.OK && response.getBody() != null && response.getBody().contains("\"return\":true")) {
        // //     logger.info("OTP sent successfully to {} via Fast2SMS.", mobileNumber);
        // // } else {
        // //     logger.error("Error sending OTP via Fast2SMS. Status: {}, Response: {}", response.getStatusCode(), response.getBody());
        // // }
    } catch (RestClientException e) {
        logger.error("Error calling Fast2SMS API for mobile number {}: {}", mobileNumber, e.getMessage(), e);
    }
    */
    // Current simulation logging:
    logger.info("SIMULATING SMS: Sending OTP {} to mobile number {} (Fast2SMS API Key: {}, URL: {})",
            otpCode, mobileNumber, fast2SmsApiKey, fast2SmsApiUrl); 
    ```
    **Important:** Always refer to the latest Fast2SMS API documentation for the correct endpoint, request parameters, expected responses, and authentication mechanism for the specific API version/route you are using (e.g., OTP, DLT, QuickTransactional).

## Environment Management

*   **Application Configuration (Spring Profiles):**
    *   The Spring Boot application uses profiles (`dev`, `qa`, `prod`) to manage environment-specific configurations.
    *   Profile-specific properties are located in `api/src/main/resources/application-<profile>.properties`.
    *   The active profile is set via the `spring.profiles.active` property or the `SPRING_PROFILES_ACTIVE` environment variable (used in the ECS task definition via the GitHub Actions workflow).
*   **Infrastructure Configuration (Terraform):**
    *   Terraform uses an `env_name` variable (e.g., `dev`, `qa`, `prod`) to prefix resource names, helping to distinguish resources from different environments.
    *   Environment-specific configurations (e.g., instance sizes, desired counts, different CIDR ranges, secrets) are managed by passing different variable values to Terraform:
        *   For local runs, this can be done via `.tfvars` files or `TF_VAR_` environment variables.
        *   For CI/CD, these variables (especially secrets) are passed from GitHub Secrets to the Terraform commands in the workflow.
*   **CI/CD (GitHub Actions):**
    *   The `.github/workflows/deploy-dev.yml` workflow is specifically for the `dev` environment.
    *   For other environments like `qa` or `prod`, you would typically:
        *   Create separate workflow files (e.g., `deploy-qa.yml`, `deploy-prod.yml`).
        *   Trigger these workflows based on pushes/merges to different branches (e.g., `release` branch for QA, `main` or tags for Production).
        *   Configure corresponding GitHub Secrets for each environment (e.g., `MONGODB_URI_QA`, `JWT_SECRET_PROD`).
        *   Adjust Terraform variables (e.g., `env_name`, `desired_count`) within the workflow for the target environment.
```
