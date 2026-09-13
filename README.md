# AWS Website CI/CD Pipeline

A dependency-free static website tested and packaged by GitHub Actions, deployed to a private
Amazon S3 bucket, and served publicly through Amazon CloudFront.

## Pipeline

`Push to main → Test → Build/package → Deploy to S3 → Invalidate CloudFront → Verify`

GitHub Actions authenticates to AWS using short-lived OIDC credentials. No AWS access keys are
stored in GitHub.

## Local validation

Requires Node.js 20 or newer.

```sh
npm test
npm run build
```

## One-time infrastructure bootstrap

Prerequisites:

- AWS CLI authenticated to the target account
- GitHub CLI authenticated to the repository owner
- The `aws-cicd-website` GitHub repository created and selected as the current remote

Deploy the CloudFormation stack and configure the GitHub Actions repository variables:

```sh
./scripts/bootstrap-aws.sh
```

The stack creates a private encrypted S3 bucket, CloudFront distribution with Origin Access
Control, and a least-privilege GitHub Actions deployment role. If the account already has the
GitHub Actions OIDC provider, the script reuses it.

## Deployment

Every push to `main` runs [the deployment workflow](.github/workflows/deploy.yml). The workflow
tests the source, builds a `dist/` artifact, synchronizes it to S3, invalidates CloudFront, and
checks that the public page contains the deployed version.

## Cleanup

CloudFormation retains the versioned S3 bucket to prevent accidental data loss. After the
assignment is reviewed, empty the bucket (including object versions), change its retention policy
if needed, and delete the `aws-cicd-website` stack. CloudFront and S3 usage can incur charges when
outside the allowances applicable to the AWS account.
