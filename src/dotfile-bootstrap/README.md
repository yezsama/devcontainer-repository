# Dotfile Bootstrap (root) (dotfile-bootstrap)

Clones `PeteJohn6/dotfile` into the root home directory and runs `bootstrap-up.sh` during feature installation.

This feature intentionally configures the container as `root`, so the repository is cloned to `/root/.dotfiles` by default and the deployed dotfiles are written under `/root`.

## Example Usage

```json
"features": {
    "ghcr.io/yezsama/devcontainer-features/dotfile-bootstrap:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| branch | Git branch to checkout before running bootstrap-up.sh. | string | master |

## Notes

- The feature runs `bootstrap-up.sh` as `root`.
- The repository URL is fixed to `https://github.com/PeteJohn6/dotfile.git`.
- The clone target is fixed to `/root/.dotfiles`.
- The dotfile repository is updated in place on rebuilds when the target directory already contains the same Git remote.
- If your dev container uses a non-root default user, its shell/profile files are not modified by this feature unless the root-owned dotfiles repo explicitly does so.
