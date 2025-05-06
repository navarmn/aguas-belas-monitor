# Filter-color-descriptor
This repo has usage of fcd with video and rtsp input.

Before configuring Docker to pull images from GAR, you must authenticate with Google Cloud using the command:

`gcloud auth activate-service-account --key-file=GOOGLE_SERVICE_ACCOUNT_CREDENTIALS.json`

`gcloud config set project plainsightai-prod`

To pull an image from Google Artifact Registry (GAR), your Docker client must be configured to authenticate with **us-west1-docker.pkg.dev**, run the below command:

`gcloud auth configure-docker us-west1-docker.pkg.dev`

## Steps to run the docker file for fcd:
- Create a `.env`, same as `env-examplee`
- Reference the correct input path and config files.
- If you need the config.json for new video, you can create it using: `docker compose -f docker-compose-config-ui.yaml up`

  This can be used on port 8001 @ http://localhost:8001
- Run the docker file for video input using the command:
`docker compose -f docker-compose-video.yaml up`
- If you want to run for rtsp input, use the command:
`docker compose -f docker-compose-rtsp.yaml up`

See the visualizations using Webvis on port 8002 @ http://localhost:8002
