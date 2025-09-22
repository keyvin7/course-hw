export TF_VAR_YC_TOKEN=$(yc iam create-token --impersonate-service-account-id ajecmapr89ld7du970pb)
export TF_VAR_YC_FOLDER_ID=$(yc config get folder-id)
export TF_VAR_YC_CLOUD_ID=$(yc config get cloud-id)

