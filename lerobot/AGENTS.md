# Repository Guidelines

## Project Structure & Module Organization
- Source code lives in `src/lerobot/` (e.g., `src/lerobot/policies`, `src/lerobot/robots`, `src/lerobot/scripts`).
- Tests are in `tests/` and should mirror the package layout (e.g., `tests/policies/test_act.py`).
- Examples in `examples/`, docs in `docs/`, assets in `media/`, Docker files in `docker/`.
- CLI entry points: `lerobot-train`, `lerobot-eval`, `lerobot-record`, `lerobot-replay`, etc. (see `pyproject.toml`).

## Build, Test, and Development Commands
- Create env and install: `pip install -e ".[dev,test]"` (Python 3.10+). For extras: `pip install -e ".[aloha,pusht]"`.
- Lint/format: `pre-commit install && pre-commit run -a` (uses Ruff, Prettier, Bandit, typos, etc.).
- Quick lint locally: `ruff format . && ruff . --fix`.
- Run unit tests: `pytest -q` or target a subset: `pytest tests -k act`.
- E2E smoke tests: `make test-end-to-end DEVICE=cpu` (see other `make test-*` targets).
- Docker builds: `make build-user` or `make build-internal`.

## Coding Style & Naming Conventions
- Python: 4-space indentation, line length 110, double quotes; import order via Ruff isort rules (`known-first-party = ["lerobot"]`).
- Naming: modules/functions `snake_case`, classes `PascalCase`, constants `UPPER_SNAKE_CASE`.
- Add type hints and docstrings (Google style preferred per tooling config). Avoid prints in library code.

## Testing Guidelines
- Framework: `pytest` with `pytest-timeout` and optional coverage. Place tests under `tests/` with files named `test_*.py`.
- Mirror package structure and use fixtures where possible. For scripts/CLIs, test via module invocation (e.g., `python -m lerobot.scripts.eval --help`).
- Include minimal datasets/artifacts or mock I/O; don’t add large binaries (pre-commit blocks them).

## Commit & Pull Request Guidelines
- Prefer Conventional Commit style: `feat(policies): add smolvla config`, `fix(dataset): guard empty episodes)`.
- PRs must include: clear description, rationale, before/after behavior, linked issues, and notes on tests/docs.
- Ensure `pre-commit` and `pytest` pass locally; add/adjust tests for behavior changes.

## Security & Configuration Tips
- Never commit secrets; `gitleaks` runs in pre-commit. Use env vars for tokens (e.g., `WANDB_API_KEY`).
- Hardware access: use helper scripts for Linux permissions (e.g., `./grant-cam.sh`, `./grant-ttyACM.sh`).
- Large files: keep out of Git; publish models/datasets to the Hugging Face Hub when appropriate.
