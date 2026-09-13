#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="${STACK_NAME:-devops-cicd-demo}"
AWS_REGION="${AWS_REGION:-us-east-1}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-devops-cicd-demo}"

for command in aws gh; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Required command not found: $command" >&2
    exit 1
  fi
done

GITHUB_OWNER=$(gh api user --jq .login)
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
OIDC_PROVIDER_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
PARAMETERS=(
  "ParameterKey=GitHubOwner,ParameterValue=${GITHUB_OWNER}"
  "ParameterKey=GitHubRepository,ParameterValue=${GITHUB_REPOSITORY}"
)

if aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn "$OIDC_PROVIDER_ARN" >/dev/null 2>&1; then
  PARAMETERS+=(
    "ParameterKey=ExistingGitHubOidcProviderArn,ParameterValue=${OIDC_PROVIDER_ARN}"
  )
fi

aws cloudformation deploy \
  --region "$AWS_REGION" \
  --stack-name "$STACK_NAME" \
  --template-file infrastructure/cloudformation.yml \
  --capabilities CAPABILITY_IAM \
  --no-fail-on-empty-changeset \
  --parameter-overrides "${PARAMETERS[@]}"

output() {
  aws cloudformation describe-stacks \
    --region "$AWS_REGION" \
    --stack-name "$STACK_NAME" \
    --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue | [0]" \
    --output text
}

AWS_ROLE_ARN=$(output GitHubActionsRoleArn)
S3_BUCKET=$(output BucketName)
CLOUDFRONT_DISTRIBUTION_ID=$(output CloudFrontDistributionId)
CLOUDFRONT_URL=$(output CloudFrontUrl)

gh variable set AWS_ROLE_ARN --body "$AWS_ROLE_ARN"
gh variable set S3_BUCKET --body "$S3_BUCKET"
gh variable set CLOUDFRONT_DISTRIBUTION_ID --body "$CLOUDFRONT_DISTRIBUTION_ID"
gh variable set CLOUDFRONT_URL --body "$CLOUDFRONT_URL"

printf 'Infrastructure ready: %s\n' "$CLOUDFRONT_URL"
