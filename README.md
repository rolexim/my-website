# rolando.solstud.io

Source for my personal site at <https://rolando.solstud.io>. The site is itself a
small portfolio piece — the same kind of work I do day-to-day, scaled down to one
domain.

## Architecture

```
                  ┌──────────────────────────────────────┐
                  │        rolando.solstud.io            │
                  └─────────────────┬────────────────────┘
                                    │ HTTPS / HTTP/3 / IPv6
                                    ▼
                       ┌────────────────────────┐
                       │  CloudFront            │
                       │  + viewer-request fn   │  rewrites /resume/ → /resume/index.html
                       │  + response-headers    │  HSTS, CSP, X-Frame-Options, etc.
                       │  + ACM cert (us-east-1)│
                       └─────────────┬──────────┘
                                     │ OAC (sigv4)
                                     ▼
                            ┌────────────────┐
                            │  S3 (private)  │  block-public-access on
                            └────────────────┘

DNS:  parent solstud.io zone (other AWS account) ──NS──► rolando.solstud.io zone
                                                         (this account)
```

- **Generator:** [Pelican](https://getpelican.com), Python, managed with `uv`.
- **Hosting:** S3 (private, OAC) + CloudFront + ACM, all in one AWS account dedicated to this site.
- **DNS:** the parent zone `solstud.io` lives in a different AWS account; it
  delegates `rolando.solstud.io` to a hosted zone in this account via NS records,
  so the site stack is self-contained.
- **IaC:** Terraform, split into `infra/bootstrap` (one-shot) and `infra/site`
  (re-applied by CI on every push to `main`).
- **State:** S3 backend with native lockfile (`use_lockfile = true`, Terraform
  1.10+) — no DynamoDB lock table needed.
- **CI/CD:** GitHub Actions; deploys assume an IAM role via OIDC, with the trust
  policy scoped to this repo + the `production` GitHub Environment.

## Repo layout

```
.
├── infra/
│   ├── bootstrap/          # state bucket + Route 53 zone + GH OIDC role (one-shot)
│   └── site/               # S3, CloudFront, ACM, alias records (re-applied by CI)
├── site/                   # Pelican source — content, theme, config
├── scripts/
│   └── generate_og_image.py
├── .github/workflows/
│   ├── ci.yml              # PR: build site, validate Terraform
│   └── deploy.yml          # main: apply, build, sync, invalidate
├── RolandoContreras.pdf    # downloadable PDF (also copied under site/content/extra/ for serving)
└── README.md
```

## Local development

Build the site locally:

```bash
cd site
uv sync
uv run pelican content -s pelicanconf.py -o output -lr
# http://localhost:8000
# -lr = --listen --autoreload: builds, serves, and rebuilds on save.
```

Preview the og:image locally (CI regenerates it on every deploy, so you don't
need to commit the PNG):

```bash
cd site && uv sync --group build
uv run python ../scripts/generate_og_image.py
# writes site/content/extra/og.png — gitignored
```

Validate Terraform without touching state:

```bash
terraform fmt -check -recursive infra/
( cd infra/bootstrap && terraform init -backend=false && terraform validate )
( cd infra/site      && terraform init -backend=false && terraform validate )
```

## First-time deploy

This is a one-shot setup; afterwards, every push to `main` deploys.

### 1. Push the repo to GitHub

The bootstrap stack hard-codes the GitHub repo into the OIDC trust policy, so
the repo has to exist first. Create an empty GitHub repo (e.g.
`rcontrerasj/my-website`) and push.

### 2. Apply the bootstrap stack

```bash
# Authenticate to the AWS account that will host the site:
aws sso login --profile <your-profile>
export AWS_DEFAULT_PROFILE=<your-profile>

cd infra/bootstrap
cp terraform.tfvars.example terraform.tfvars
$EDITOR terraform.tfvars       # set github_repository

terraform init
terraform apply
```

This creates the state bucket, Route 53 hosted zone, GitHub OIDC provider, and
the deploy role. Note the outputs:

- `state_bucket`
- `deploy_role_arn`
- `zone_name_servers` (4 NS records)

### 3. Delegate the subdomain (one-time, in the parent account)

In the AWS account that owns the `solstud.io` zone, add a record:

```
Name:    rolando.solstud.io
Type:    NS
TTL:     300
Records: <the four NS values from `zone_name_servers`>
```

Verify:

```bash
dig +short NS rolando.solstud.io
```

### 4. Configure GitHub Actions

In the repo's **Settings → Secrets and variables → Actions**, add:

| Kind     | Name                  | Value                                     |
|----------|-----------------------|-------------------------------------------|
| Variable | `AWS_DEPLOY_ROLE_ARN` | `deploy_role_arn` from bootstrap output   |
| Variable | `TF_STATE_BUCKET`     | `state_bucket` from bootstrap output      |
| Secret   | `CF_ANALYTICS_TOKEN`  | (optional) Cloudflare Web Analytics token |

In **Settings → Environments**, create an environment named `production`. Add
yourself as a required reviewer if you want a human gate before each apply.

### 5. Push to `main`

GitHub Actions runs `deploy.yml`:

1. Assumes `AWS_DEPLOY_ROLE_ARN` via OIDC.
2. `terraform apply` against `infra/site` — creates the S3 bucket, ACM cert
   (validated via DNS in the just-delegated subdomain zone), CloudFront
   distribution, and alias records.
3. Builds the Pelican site.
4. Syncs to S3 with cache-control headers (longer TTL for static assets, shorter
   for HTML).
5. Issues a CloudFront invalidation for `/*`.

The first apply waits for ACM validation, which depends on the NS delegation
from step 3 having propagated. After that, deploys take ~1–2 minutes.

## Verification checklist

After the first deploy:

```bash
dig +short NS rolando.solstud.io                            # NS delegation OK
curl -I https://rolando.solstud.io                          # 200, HSTS, CSP
curl -I https://rolando.solstud.io/RolandoContreras.pdf     # 200, application/pdf
curl    https://rolando.solstud.io/sitemap.xml | head       # absolute URLs
curl -I https://rolando.solstud.io/resume/                  # 200 (CF function rewrite)
```

## Updating content

Edit `site/content/pages/resume.md` (and the source PDF if needed), commit,
push. CI takes care of the rest.

## Costs

A static resume site is essentially free at this scale: under $1/mo for CloudFront,
S3, and Route 53 combined. ACM certs are free.
