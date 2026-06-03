# demo-cicd

A minimal demo for a CI/CD pipeline: a tiny Python HTTP server, unit tests, and a
GitHub Actions workflow that assumes an AWS role, runs the tests, and builds a
multi-arch Docker image.

## Layout

| File | Purpose |
|------|---------|
| `app.py` | Stdlib HTTP server — returns `200 OK` on `/`, `404` elsewhere. |
| `test_app.py` | `unittest` tests for the two routes. |
| `Dockerfile` | Multi-arch image (built via buildx). |
| `.github/workflows/ci.yml` | CI: `test` job → `build` job (assume-role + buildx push). |

## Run locally

```bash
python3 app.py            # serves on 0.0.0.0:8080
curl localhost:8080/     # -> OK
python3 -m unittest -v    # run tests
```

## Docker

```bash
docker build -t demo-cicd .
docker run -p 8080:8080 demo-cicd
```

## CI notes

The workflow uses `XXXX` as the version/ref for every `uses:` action — **pin each
to a tag or commit SHA before running** (e.g. `actions/checkout@v4`).

Other placeholders to fill in:

- `<ACCOUNT_ID>` — your AWS account ID (in `IMAGE_REPO` and the role ARN).
- `<CI_ROLE_NAME>` — the IAM role the workflow assumes via GitHub OIDC.
- `AWS_REGION` / `IMAGE_REPO` — adjust region and registry path as needed.

The `build` job depends on `test`, so the image only builds when tests pass.
Authentication uses GitHub OIDC (`id-token: write`) — no static AWS keys.
