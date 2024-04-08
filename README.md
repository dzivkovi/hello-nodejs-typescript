# From Jenkins to Buildpacks

## Streamlining GCP Deployments with Cloud Native Buildpacks

In our current setup, the reliance on an on-premise Jenkins server for building Docker images in a local container image registry has been notably resource-intensive. This process consumes a considerable amount of CPU resources, which not only slows down the server but also adversely affects other build and deploy jobs running concurrently on the same Jenkins server. This repository introduces a more efficient alternative by leveraging Cloud Native Buildpacks for deploying applications to Google Cloud Run. This method significantly reducing the load on local servers by utilizing cloud resources for the build process. This streamlined approach does not necessitate a full migration away from Jenkins but offers a lightweight cloud-native solution to replace the container building logic, preserving server resources and enhancing overall efficiency.

## Key Features

- **Efficient Resource Usage**: By moving the build process to the cloud, it significantly reduces the consumption of local CPU resources, mitigating the slowdown of servers and ensuring that other jobs on Jenkins can run without impact.
- **Language Detection**: Automatically identifies the programming language of your application, facilitating a smoother build process without manual intervention.
- **Dockerfile Independence**: Eliminates the need for writing and maintaining Dockerfiles, thereby simplifying the deployment process.
- **Seamless GCP Integration**: Offers a tightly integrated experience with Google Cloud services, leveraging the cloud for builds and deployments.
- **Configuration Reuse**: Utilizes existing configuration from Jenkins `manifest.yml` files, streamlining the transition to cloud-native build processes without the need for the code/repo modifications.

## Simplicity at Its Core

Our approach adopts Cloud Native Buildpacks and Google Cloud Run to simplify our build and deployment processes. This not only simplifies the development lifecycle but also represents a significant step towards a more streamlined, cloud-native paradigm.

### Cloud Native Buildpacks

- Transition from traditional Jenkins container build stages to a single, simplified command line using Buildpacks.
- This method also eliminates the need for `cloudbuild.yaml`:

    ```bash
    gcloud builds submit --pack image=gcr.io/[PROJECT_ID]/[APPLICATION_NAME]
    ```

### Cloud Run Deployments

- Effortlessly create or select a Cloud Run service for deployment. This step further simplifies the deployment process:

    ```bash
    gcloud run deploy [APPLICATION_NAME] --image=gcr.io/[PROJECT_ID]/[APPLICATION_NAME]
    ```

These steps demonstrate the straightforwardness and efficiency of leveraging the latest services provided by Google, showcasing the innovation that drives impactful technology solutions.

## Scripts

### `cr_build.sh`

This script facilitates the building of applications for GCP Cloud Run deployment using Cloud Native Buildpacks, leveraging configurations from a Jenkins `manifest.yml` file. It embodies the shift towards efficient cloud-based builds, offering a solution that alleviates the resource constraints imposed by traditional on-premise building methods.

### `cr_deploy.sh`

Deploys the containerized application to GCP Cloud Run, using configurations from the Jenkins `manifest.yml` file. This script further exemplifies the move towards a cloud-native deployment approach, optimizing resource usage by leveraging the cloud for deployment tasks.

## Getting Started

1. **Clone this Repository**: Start by cloning this repository to access the deployment scripts.
2. **Set Deployment Target**: Define `DEPLOYMENT_TARGET` to specify your intended deployment environment.
3. **Build the Application**: Run `cr_build.sh` to build your application image using Cloud Build and Buildpacks, utilizing cloud resources instead of local server resources.
4. **Deploy**: Execute `cr_deploy.sh` to deploy your application to Cloud Run, benefiting from a cloud-native deployment process.

## Resources

- **[Cloud Native Buildpacks](https://buildpacks.io/)**: Discover more about the methodology and advantages of using Cloud Native Buildpacks.
- **[Google Cloud Buildpacks Documentation](https://cloud.google.com/docs/buildpacks/build-application)**: Explore comprehensive guides on building applications with Google Cloud Buildpacks.
- **[Jenkins Manifest V2](https://cogeco.atlassian.net/wiki/spaces/DEVOPS/pages/2461499486/Manifest+V2+Cloud+run+nodejs)**: Example of current YAML file.

## Feedback and Contributions

Your feedback and contributions are highly appreciated. If you have suggestions, questions, or encounter issues, please feel free to open an issue or submit a pull request. Together, we can refine this tool to better serve the community.
