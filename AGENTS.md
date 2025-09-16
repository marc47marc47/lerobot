# Repository Guidelines

## Project Structure & Module Organization
- `src/lerobot/` contains the Python package, grouped by feature (e.g., `policies/`, `robots/`, `transport/`). Changes should follow the existing module boundaries.
- `tests/` mirrors the source tree with fixtures in `tests/fixtures/` and long-running artifacts under `tests/outputs/`; keep new tests close to the code they cover.
- `docs/` hosts the rendered documentation sources, while `examples/` provides runnable notebooks and scripts for quick starts.
- Top-level scripts such as `train-local.sh`, `record-local.sh`, and utilities in `docker/` support local and container workflows; update these when interfaces change.

## Build, Test, and Development Commands
- `pip install -e ".[dev,test]"` installs the library with developer dependencies; run from the repo root after creating a Python 3.10 environment.
- `ruff check src tests` and `ruff format src tests` apply the configured formatter and lint rules; run `pre-commit run --all-files` if you enable hooks.
- `pytest` runs the unit suite; use `pytest tests/policies -k act` to target a submodule.
- `make test-end-to-end DEVICE=cpu` executes the integration flow that exercises training and evaluation pipelines.
- `lerobot-train --config_path train-local.yaml` and companion scripts in `examples/` are the quickest way to validate changes against real configs.

## Coding Style & Naming Conventions
- Python code targets 3.10+, uses spaces for indentation, and keeps line length within 110 characters.
- Ruff enforces double quotes, sorted imports, and `pep8-naming`; follow existing patterns such as `CamelCase` for classes and `snake_case` for public functions.
- Prefer explicit module paths inside `src/lerobot`, and document complex routines with Google-style docstrings when needed.

## Testing Guidelines
- Add `pytest` tests in the matching folder under `tests/`; name files `test_<feature>.py` and functions `test_<behavior>`.
- Use provided fixtures from `tests/fixtures` and mock helpers under `tests/mocks` to avoid hardware dependencies.
- Store generated data in `tests/outputs/<suite>` and clean up large artifacts after assertions.

## Commit & Pull Request Guidelines
- Follow the existing convention of descriptive messages, optionally prefixed with a scope (e.g., `fix(scripts): ensure rs config import (#1876)`).
- Reference the related issue or discussion in the body, and include before/after context or screenshots for UI-affecting work.
- Pull requests should call out testing performed, mention affected hardware setups, and update docs or examples when behavior changes.
