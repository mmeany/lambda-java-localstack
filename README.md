
# Lambda Bash Project

A Gradle multi-module project for AWS Lambda functions with comprehensive testing and deployment capabilities.

## Project Structure

```
lambda-bash/
├── settings.gradle                    # Gradle settings with multi-module configuration
├── build.gradle                       # Root build script (Groovy)
├── gradle/
│   └── libs.versions.toml            # TOML dependencies catalogue
├── lambda-module/                     # AWS Lambda module
│   ├── build.gradle                  # Module build script
│   └── src/
│       ├── main/java/com/example/lambda/
│       │   ├── LambdaHandler.java    # Lambda entry point
│       │   └── Processor.java        # Business logic processor
│       └── test/java/com/example/lambda/
│           ├── LambdaHandlerTest.java           # Unit tests
│           └── ProcessorTest.java               # Unit tests
└── scripts/                          # Deployment and testing scripts
    ├── create-role.sh                # IAM role creation script
    ├── deploy.sh                     # Lambda deployment script
    ├── invoke.sh                     # Lambda invocation script
    ├── sample-payload.json           # Sample JSON payload
    └── simple-payload.json           # Simple JSON payload
```

## Actions Taken

### 1. Gradle Multi-Module Setup
- Created `settings.gradle` with Groovy syntax for multi-module configuration
- Implemented `build.gradle` with Java 17 toolchain and common configurations
- Set up TOML dependencies catalogue in `gradle/libs.versions.toml` with versions for:
  - AWS Lambda Java Core & Events
  - Jackson for JSON processing
  - Lombok for code generation
  - JUnit 5 for testing
  - Mockito for unit testing
  - SLF4J and Logback for logging

### 2. Lambda Module Implementation
- **LambdaHandler.java**: Main Lambda entry point implementing `RequestHandler<String, String>`
  - Accepts JSON string input
  - Validates JSON format using Jackson
  - Delegates processing to Processor class
  - Handles errors gracefully with proper logging
- **Processor.java**: Business logic class
  - Processes JSON input and logs the structure
  - Returns success message (extensible for future business logic)
  - Uses Lombok for logging annotations

### 3. Build Configuration
- Configured Shadow plugin for creating deployable JAR
- Set up proper manifest with main class
- Configured JAR naming for AWS deployment compatibility

### 4. Testing Implementation
- **Unit Tests**: Comprehensive test coverage for both LambdaHandler and Processor
  - Valid JSON processing
  - Invalid JSON error handling
  - Edge cases (empty JSON, null input)
  - Uses Mockito for mocking AWS Lambda Context

### 5. Deployment Scripts
- **create-role.sh**: IAM role creation for Lambda function
  - Creates Lambda execution role with proper trust policy
  - Attaches basic execution policy for CloudWatch logs
  - Outputs role ARN to `role-arn.txt` file
  - Handles existing role detection
- **deploy.sh**: Automated Lambda deployment
  - Reads IAM role ARN from `role-arn.txt` file
  - Supports AWS profile configuration
  - Handles both new function creation and updates
  - Configurable function name and region
  - Outputs function ARN to `function-arn.txt` file
- **invoke.sh**: Lambda function invocation
  - JSON payload validation
  - Error handling and response formatting
  - Configurable function name and region

## Usage Instructions

### Prerequisites
- Java 17 or higher
- Gradle 7.0 or higher
- AWS CLI configured with appropriate profiles

### Building the Project
```bash
# Build the entire project
./gradlew build

# Build only the Lambda module
./gradlew :lambda-module:build

# Run tests
./gradlew test
```

### Creating IAM Role
```bash
# Create IAM role with default settings
./scripts/create-role.sh my-aws-profile

# Create IAM role with custom name and region
./scripts/create-role.sh my-aws-profile my-lambda-role us-west-2
```

### Deploying to AWS
```bash
# Deploy with default settings (requires role-arn.txt from create-role.sh)
./scripts/deploy.sh my-aws-profile

# Deploy with custom parameters
./scripts/deploy.sh my-aws-profile my-function-name us-west-2
```

### Invoking the Lambda
```bash
# Invoke with sample payload
./scripts/invoke.sh my-aws-profile scripts/sample-payload.json

# Invoke with custom function name and region
./scripts/invoke.sh my-aws-profile scripts/simple-payload.json my-function-name us-west-2
```


## LocalStack Considerations

When using LocalStack with an AWS profile named `localstack`, consider the following:

### 1. AWS Profile Configuration
Ensure your `~/.aws/credentials` file contains:
```ini
[localstack]
aws_access_key_id = test
aws_secret_access_key = test
region = us-east-1
```

### 2. LocalStack Endpoint Configuration
The integration tests automatically configure LocalStack endpoints. For manual testing, ensure LocalStack is running:
```bash
docker run -d -p 4566:4566 localstack/localstack
```

### 3. IAM Role Considerations
LocalStack uses a simplified IAM model. The integration tests use a basic role ARN:
```
arn:aws:iam::000000000000:role/lambda-execution-role
```

### 4. Deployment to LocalStack
To deploy to LocalStack instead of real AWS:
```bash
# Set LocalStack endpoint
export AWS_ENDPOINT_URL=http://localhost:4566

# Create role for LocalStack
./scripts/create-role.sh localstack lambda-execution-role us-east-1

# Deploy using localstack profile
./scripts/deploy.sh localstack my-function-name us-east-1
```

### 5. Invocation with LocalStack
```bash
# Invoke function deployed to LocalStack
./scripts/invoke.sh localstack scripts/sample-payload.json my-function-name us-east-1
```

### 6. Special Notes for LocalStack
- LocalStack may have different behavior for some AWS services
- Function cold starts might be faster in LocalStack
- Some advanced Lambda features might not be fully supported
- Always test critical functionality in real AWS environment before production deployment

## Development Workflow

1. **Make changes** to Lambda code in `lambda-module/src/main/java/`
2. **Run unit tests**: `./gradlew test`
3. **Build project**: `./gradlew build`
4. **Create IAM role**: `./scripts/create-role.sh localstack` (for LocalStack) or `./scripts/create-role.sh production-profile` (for AWS)
5. **Deploy to LocalStack**: `./scripts/deploy.sh localstack`
6. **Test locally**: `./scripts/invoke.sh localstack scripts/sample-payload.json`
7. **Deploy to AWS**: `./scripts/deploy.sh production-profile`
8. **Test in AWS**: `./scripts/invoke.sh production-profile scripts/sample-payload.json`

## Generated Files

The deployment process creates the following files:
- `role-arn.txt`: Contains the IAM role ARN created by `create-role.sh`
- `function-arn.txt`: Contains the Lambda function ARN created by `deploy.sh`

These files are used by the scripts to maintain state between deployments and can be referenced for other AWS operations.
