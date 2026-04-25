Title: Projects
Slug: projects
Summary: Selected projects and the source code behind this site.

## This site

The site you're reading is itself a small infrastructure-as-code project, built to
demonstrate the same skills my resume describes.

- **Hosting:** S3 (private, OAC) + CloudFront + ACM, in a single AWS account
  dedicated to this site.
- **DNS:** Route 53 hosted zone for the site's subdomain, delegated from the
  parent zone in a separate AWS account.
- **IaC:** Terraform, split into a one-shot `bootstrap` stack (state bucket,
  GitHub OIDC role, hosted zone) and a `site` stack (S3, CloudFront, ACM,
  alias records). Remote state in S3 with native S3 locking (Terraform 1.10+).
- **CI/CD:** GitHub Actions. PRs run a build; pushes to `main` assume an AWS
  role via OIDC, run `terraform apply`, build with Pelican, sync to S3, and
  invalidate CloudFront.
- **Generator:** Pelican (Python, UV-managed) with a custom minimal theme.

Source: [{{ GITHUB_REPO_URL.replace('https://', '') }}]({{ GITHUB_REPO_URL }})

## Portfolio repository

A separate repo for larger projects is in progress. I'll link it here once the
first project is up.
