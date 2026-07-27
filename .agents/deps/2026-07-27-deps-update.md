# GitHub Actions dependency refresh

Pull request #12 updated the exact `actions/checkout` workflow pin from 7.0.0
to 7.0.1. The dependency change passed both repository validation jobs before
it was merged normally.

Evidence:

- `Home Assistant App` GitHub Actions check: passed
- `Runtime and container` GitHub Actions check: passed
- merge commit: `8a18a766f40e03b99a6f16a01e8e67e7f8e150e0`
