# Gitlab Gitops with Infra-as-Code
Use the Gitlab provided Terraform runner to validate, plan, apply and destroy terraform modules.

## Prereqs

### Gitlab CI Runners
The Gitlab instance must have a Docker "Instance" runner registered and online.

### GitLab Project
As Gitlab admin:
1. Admin > Users > New User
   - Name: jeff
   - Username: jeff
   - Save
2. Admin > Groups > New group
   - Group name: codebeneath
   - Save
3. Admin > Groups > codebeath > Group members > Manage access
   - Invite members
   - Username: jeff
   - Maximum role: Owner

As regular user:
1. Groups > codebeneath > New project
   - Project name: tf
   - Project URL: http://$PUBLIC_IP/codebeneath/tf
   - Save
2. Clone the repo, then copy these files into the folder.
3. Commit and push

### First iteration creds
First iteration uses Gitlab CI vars, restricted to the repo "Owner", for Terraform AWS provider creds.

```
TF_VAR_AWS_ACCESS_KEY_ID       masked & hidden value
TF_VAR_AWS_SECRET_ACCESS_KEY   masked & hidden value
TF_VAR_AWS_SESSION_TOKEN       masked & hidden value
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
Second iteration uses OIDC for AWS assumed roles for Terraform AWS provider creds. It also uses the Amazon ECR Credential Helper to faciliate Docker login for the assummed role.

Create/import this project into Gitlab.

Gitlab project CI vars
```
ACCOUNT_ID: <ACCOUNT-ID>
AWS_DEFAULT_REGION: us-east-2

curl --request POST --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "https://gitlab.codebeneath-labs.org/api/v4/projects/1/variables" --form "key=ACCOUNT_ID" --form "$(aws sts get-caller-identity --query 'Account' --output text)"
curl --request POST --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" "https://gitlab.codebeneath-labs.org/api/v4/projects/1/variables" --form "key=AWS_DEFAULT_REGION" --form "value=us-east-2"
```

```
variables:
  AWS_ROLE_ARN: "arn:aws:iam::$ACCOUNT:role/codebeneath-lab-gitlab-runner-role"

default:
  id_tokens: # Request an OIDC token
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.codebeneath-labs.org
  before_script:
    - >
      aws_sts_output=$(aws sts assume-role-with-web-identity
      --role-arn ${AWS_ROLE_ARN}
      --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token ${GITLAB_OIDC_TOKEN}
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text)
    - export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" $aws_sts_output)
    - aws sts get-caller-identity
    - cd ${TF_ROOT}
    - terraform --version
```

