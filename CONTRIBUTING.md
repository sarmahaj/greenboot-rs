#### Test Coverage Requirements

This project reports test coverage through Codecov:

- **Project coverage:** 75% target.
- **Patch coverage:** 75% target for new/changed code in PRs

These checks are not currently required for merging.

Coverage is reported through:

1. `cargo-llvm-cov` - Generates the coverage report (`tests/coverage/lcov.info`) as part of the `build_and_test_with_coverage` CI job
2. **Codecov** - Reports coverage trends and fails CI if the project/patch thresholds defined in `codecov.yml` are not met

**Before submitting a PR:**

```bash
# Run tests with coverage (installs cargo-llvm-cov automatically if missing;
# requires llvm-cov/llvm-profdata, e.g. `sudo dnf install llvm`, and uses sudo
# internally for some steps)
make test-coverage-check

# View the HTML report
xdg-open tests/coverage/html/index.html
```

This will report three sections, `Missed Lines`, `Missed Functions`, and `Missed Regions`. We only use the `Missed Lines` for checking coverage, but the `Missed Functions` and `Missed Regions` are useful for quickly learning where you are missing coverage. 

PRs that drop coverage below these thresholds will fail CI. Add tests to ensure your changes meet the coverage requirements.

If your PR would drop the coverage by a meaningful amount, even if it is still within the threshold, you may be asked to add extra tests.