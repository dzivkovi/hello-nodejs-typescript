#!/bin/bash
# cr_deploy.sh script deploys an application to GCP Cloud Run.
# It leverages values from a Jenkins manifest.yml file to configure the deployment.
# It's intended to be run in a CI/CD pipeline, but can be run locally for "demo"s.

# Default Cloud Run settings
CPU="1"           # A higher CPU allocation relates to shorter cold starts
CONCURRENCY="80"
TIMEOUT="300"
AUTHENTICATION=   # Do not allow unauthenticated requests by default.
# Pass the authentication token in the header, instead:
# curl -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" https://your-service-url

# Target deployment environment
# Select the correct .env file based on deployment target (add more as needed)
if [[ "$DEPLOYMENT_TARGET" == "demo" ]]; then
  ENV_FILE=".env.dev"
  # Avoid GCP charges when 'demo' environment is not in use
  DEPLOYMENT_MININSTANCE=0
  AUTHENTICATION="--allow-unauthenticated"
elif [[ "$DEPLOYMENT_TARGET" == "dev" ]]; then
  ENV_FILE=".env.dev"
elif [[ "$DEPLOYMENT_TARGET" == "uat" ]]; then
  ENV_FILE=".env.uat"
elif [[ "$DEPLOYMENT_TARGET" == "stg" ]]; then
  ENV_FILE=".env.stg"
elif [[ "$DEPLOYMENT_TARGET" == "prod" ]]; then
  ENV_FILE=".env.prod"
else
  echo "Error: DEPLOYMENT_TARGET environment variable not set or invalid. Use one of: demo, dev, uat, stg, prod"
  exit 1
fi
echo "Deployment target: $DEPLOYMENT_TARGET"

# Function to check required variables are set
check_required_vars() {
    local required_vars=("$@")  # Accepts an array of required variable names as arguments

    for var_name in "${required_vars[@]}"; do
        if [[ -z "${!var_name}" ]]; then  # Indirect expansion to check if the variable is empty
            echo "Error: Variable $var_name is missing. Please ensure it's defined." >&2
            exit 1
        else
            echo "Variable: $var_name=${!var_name}"
        fi
    done
}

# Extract Values from manifest.yaml
echo "Parsing manifest.yml file..."

# Function to read a value from the manifest.yaml file
# using https://github.com/mikefarah/yq to parse YAML 
get_manifest_value() {
  yq eval ".$1" manifest.yml
}

TEAM=$(get_manifest_value team)
APPLICATION_NAME=$(get_manifest_value application.name)
DEPLOYMENT_MEMORY=$(get_manifest_value deployment.memory)
DEPLOYMENT_MININSTANCE=$(get_manifest_value deployment.minInstance) 
DEPLOYMENT_MAXINSTANCE=$(get_manifest_value deployment.maxInstance)

APPLICATION_RUNTIME_VERSION=$(get_manifest_value application.runtime_version)
# TODO: Use for container build process:
# $ gcloud builds submit --pack image=${IMAGE_URI},env="GOOGLE_RUNTIME_VERSION=$APPLICATION_RUNTIME_VERSION" --project=$PROJECT_ID

# Required Variables (add any others you need)
required_vars=(TEAM APPLICATION_NAME DEPLOYMENT_MEMORY 
               DEPLOYMENT_MININSTANCE DEPLOYMENT_MAXINSTANCE
               APPLICATION_RUNTIME_VERSION
              )

check_required_vars "${required_vars[@]}"

required_vars=(
               PROJECT_ID REGION 
              )
echo "Finding GCP Project ID and Region..."

# Assuming all deployments are in the same region
REGION=$(gcloud config get-value compute/region)

if [[ "$DEPLOYMENT_TARGET" == "demo" ]]; then
  PROJECT_ID=$(gcloud config get-value project)
else
  PROJECT_ID=$(./manifest_parser.sh $DEPLOYMENT_TARGET)
fi

required_vars=(
               PROJECT_ID REGION 
              )
check_required_vars "${required_vars[@]}"

# If we reach here, all required variables have values
echo "All required variables are present."

# Build the gcloud run deploy command with environment variables
# Construct the --set-env-vars argument dynamically

echo "Parsing .env files..."

env_vars_list=""  # Initialize as an empty string
while IFS="=" read -r key value; do
  # Skip empty lines and lines starting with '#'
  if [[ -n "$key" && ! "$key" =~ ^# ]]; then
      if [[ -z "$env_vars_list" ]]; then
        env_vars_list="$key=$value" 
      else
        env_vars_list="$env_vars_list,$key=$value" 
      fi
  fi
done < <(grep -Ev "^$|^#" $ENV_FILE)  # Process substitution 

echo "Container runtime properties: $env_vars_list" 

# NOTE: Using TEAM name for organizing container artifacts 
IMAGE_URI="gcr.io/${PROJECT_ID}/${TEAM}/${APPLICATION_NAME}"

# Build the gcloud run deploy command 
deploy_cmd="gcloud run deploy ${APPLICATION_NAME} $AUTHENTICATION \
     --platform managed \
     --project $PROJECT_ID \
     --region $REGION \
     --image $IMAGE_URI \
     --cpu $CPU \
     --timeout $TIMEOUT \
     --concurrency $CONCURRENCY \
     --memory $DEPLOYMENT_MEMORY \
     --min-instances $DEPLOYMENT_MININSTANCE \
     --max-instances $DEPLOYMENT_MAXINSTANCE"

# Load variables from .env file, handling PORT specifically
while IFS="=" read -r key value; do
  # Skip empty lines and lines starting with '#'
  if [[ -n "$key" && ! "$key" =~ ^# ]]; then
    if [[ $key == "PORT" ]]; then
      deploy_cmd="$deploy_cmd --port $value"
      echo "PORT=$value passed to deploy command, not into container environment!"
    else
      deploy_cmd="$deploy_cmd --set-env-vars $key=$value"
    fi
  fi
done < <(grep -Ev "^$|^#" $ENV_FILE)

echo "Deploy Command:"
echo "$deploy_cmd"
eval $deploy_cmd
