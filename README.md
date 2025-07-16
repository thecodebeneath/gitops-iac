# Gitlab Gitops with Infra-as-Code
Use the Gitlab provided Terraform runner to validate, plan, apply and destroy terraform modules.

## Prereqs


### First iteration creds
First iteration uses Gitlab CI vars, restricted to the repo "Owner", for Terraform AWS provider creds.

```
TF_VAR_AWS_ACCESS_KEY_ID       masked & hidden value
TF_VAR_AWS_SECRET_ACCESS_KEY   masked & hidden value
TF_VAR_AWS_SESSON_TOKEN        masked & hidden value
TF_VAR_AWS_REGION              "us-east-2"
```

To get the session token for manual CLI testing of the Terraform
```
aws sts get-session-token --duration-seconds 3600

vi codebeneath.tfvars

AWS_ACCESS_KEY_ID = "PLACEHOLDER"
AWS_SECRET_ACCESS_KEY = "PLACEHOLDER"
AWS_SESSION_TOKEN = "PLACEHOLDER"
AWS_REGION = "us-east-2"

terraform plan -var-file=codebeneath.tfvars
```

### Second iteration creds
Second iteration uses OIDC for AWS assumed roles for Terraform AWS provider creds.

```
variables:
  AWS_ROLE_ARN: "arn:aws:iam::MY_ACCOUNT_ID:role/GitlabIacRole"
  AWS_WEB_IDENTITY_TOKEN_FILE: "${CI_PROJECT_DIR}/aws_oidc_token.json" # Standard practice
  AWS_ROLE_SESSION_NAME: "GitlabIac-${CI_JOB_ID}"

default:
  id_tokens: # Request an OIDC token
    GITLAB_OIDC_TOKEN:
      aud: # Optional: specify audience if required by your IdP config in AWS
        - https://git.codebeneath.org
  before_script:
    - echo "${GITLAB_OIDC_TOKEN}" > ${AWS_WEB_IDENTITY_TOKEN_FILE}
    # Terraform AWS provider will automatically pick up AWS_ROLE_ARN and AWS_WEB_IDENTITY_TOKEN_FILE
```
