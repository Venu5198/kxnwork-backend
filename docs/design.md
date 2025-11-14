flowchart LR
  GH[GitHub Repo]
  GHActions[GitHub Actions CI/CD]
  Artifact[Artifact Registry]
  GCP_VPC[VPC]
  VM[Compute Engine VM]
  Users[Users / Clients]

  GH -->|push| GHActions
  GHActions -->|build & push| Artifact
  GHActions -->|deploy| VM
  Artifact -->|image pull| VM
  Users -->|HTTP| VM
  VM -->|logs/metrics| Stackdriver[Cloud Logging & Monitoring]

