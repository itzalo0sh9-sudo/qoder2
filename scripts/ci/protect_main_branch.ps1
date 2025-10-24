<#
.scripts/ci/protect_main_branch.ps1

Purpose:
 - Apply recommended branch protection rules for `main` using the GitHub CLI (`gh`).
 - This script requires `gh` to be installed and authenticated with repo admin privileges.

USAGE
 - Run `gh auth login` locally, then: `.	ests\scripts\ci\protect_main_branch.ps1` from the repo root.

#> 

param(
    [string]$Repo = "itzalo0sh9-sudo/qoder2",
    [string]$Branch = "main"
)

Write-Host "Applying branch protection to $Repo:$Branch"

# Require PR reviews (1) and require status checks to pass (smoke-ci)
gh api --method PUT "/repos/$Repo/branches/$Branch/protection" --input - <<JSON
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["smoke-ci"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1
  },
  "restrictions": null
}
JSON

Write-Host "Branch protection applied. Verify in GitHub UI: Settings → Branches"
