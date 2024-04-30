# SonarQube Analysis Setup for Node.js/Typescript Projects

## Configuration

### SonarCloud Project Setup

- Create a project on [SonarCloud.io](https://sonarcloud.io) to obtain your unique project key and organization ID.
- Navigate to your project's configuration page, typically under `https://sonarcloud.io/project/configuration?id=your_project_key` to setup your Analysis Method.
- Here is the corresponding [SonarCloud project](https://sonarcloud.io/project/configuration?id=dzivkovi_hello-nodejs-typescript) for this POC.
- Set up the `SONAR_TOKEN` environment variable with your SonarCloud token. In Windows:

    ```bash
    set SONAR_TOKEN=your_sonarqube_token
    ```

    Or in Unix-based systems:

    ```bash
    export SONAR_TOKEN=your_sonarqube_token
    ```

### Local Environment Setup

These steps are optional if you are using Google Cloud Build for CI/CD.

- Ensure Java and Maven are correctly installed and configured on your system.
- Download the SonarScanner CLI from the [official website](https://docs.sonarsource.com/sonarqube/latest/analyzing-source-code/scanners/sonarscanner/).
- Modify the PATH environment variable to include the location of your SonarScanner's `bin` directory.

#### SonarQube Validation (Windows)

For direct analysis using SonarScanner, configure the scanner and execute the following in your project's root directory:

```bash
sonar-scanner -D'sonar.host.url=https://sonarcloud.io'
```

## Google Cloud Build CI/CD Integration

The solution is based on the [official Docker image](https://hub.docker.com/_/sonarqube) provided by the SonarQube platform. The Google Community contributed [image for SonarQube Scanner](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/sonarqube) did not work, nor was I able to create a working cross-language alternative (other than Java).

To integrate SonarQube analysis into Google Cloud Build, use the following command:

```bash
export PROJECT_ID=$(gcloud config get-value project)

gcloud builds submit --config cloudbuild-sonar.yaml --substitutions=_SONAR_TOKEN="$SONAR_TOKEN"
```

The "magic" is in the `[cloudbuild-sonar.yaml](cloudbuild-sonar.yaml)` file and mounting the source code repo into the SonarQube Docker container.

### Scanner Reports

SonarQube Scanner Report for this POC:

- [Dashboard](https://sonarcloud.io/dashboard?id=dzivkovi_hello-nodejs-typescript)
- [API](https://sonarcloud.io/api/qualitygates/project_status?projectKey=dzivkovi_hello-nodejs-typescript)

## Notes

- Learn more about [SonarScanner CLI](https://www.sonarqube.org/).
- Regularly execute your SonarQube scanner to keep up with new features and security patches.
- Always ensure your `SONAR_TOKEN` is kept secure and not hardcoded in your configuration files.
- In production, use Google Cloud's Secret Manager to store/access sensitive information like the SonarQube token.
