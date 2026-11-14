# dotfiles

Setup for an Apple Silicon Mac, driven by [mise](https://mise.jdx.dev). mise
installs the tools and Homebrew formulae, links the dotfiles, and runs the
setup tasks. Homebrew is only needed for the casks in `script/Brewfile`.

## Layout

| Path | Contents |
|---|---|
| `home/` | A mirror of `$HOME`. Every file Git tracks here is symlinked to the same path under `~`. |
| `home/.config/mise/config.toml` | The global mise config: tools, Homebrew formulae, App Store apps, the login shell and the dotfile links. It is linked to `~/.config/mise/config.toml` like any other dotfile. |
| `mise.toml` | The setup tasks (`mise run setup`, `mise run link`, ...). |
| `script/Brewfile` | Homebrew casks: GUI apps and fonts. |
| `script/neovim.sh`, `script/agents.sh` | Helpers that the `nvim` and `agents` tasks run. |
| `bootstrap.sh` | The entry point for a new Mac. |

The Neovim config is a separate repository,
[amikai/nvimrc](https://github.com/amikai/nvimrc). It is cloned into
`home/.config/nvim/`, which this repository ignores.

## First install

Requirements:

- An Apple Silicon Mac. mise's Homebrew formula manager is not available on
  Intel Macs.
- The repository at `~/Workspace/dotfiles`. The mise config finds the dotfiles
  at that path.

```sh
git clone https://github.com/amikai/dotfiles ~/Workspace/dotfiles
~/Workspace/dotfiles/bootstrap.sh
```

On a new Mac, the first `git` command offers to install the Xcode Command Line
Tools; install them, then run `git clone` again.

Run `bootstrap.sh` in a terminal. Some steps ask for your password: installing
Homebrew, adding zsh to `/etc/shells`, and casks that ship a `.pkg` installer.

`bootstrap.sh` installs Homebrew (for the casks) if it is missing, installs
mise to `~/.local/bin` with its [official installer](https://mise.jdx.dev/installing-mise.html)
if it is missing, trusts `mise.toml`, and runs `mise run setup`. The `setup` task runs these tasks in
order:

1. `packages`: Homebrew formulae and App Store apps from `[bootstrap.packages]`.
2. `casks`: the casks in `script/Brewfile`.
3. `link`: clones nvimrc if it is missing, then links `home/` into `~`.
4. `login-shell`: makes Homebrew's zsh the login shell.
5. `tools`: the mise `[tools]`, such as languages, CLIs and language servers.
6. `services`: the LaunchAgent that updates the coding agent CLIs every hour.
7. `nvim`: updates nvimrc and syncs its plugins.
8. `agents`: installs agent skills and the herdr integrations.

`setup` stops at the first task that fails. Fix the cause and run
`mise run setup` again; every task is safe to repeat, and you can also run any
of them alone. When `setup` finishes, start a new login shell.

## Day to day

Run `mise` commands from `~/Workspace/dotfiles`, or add
`-C ~/Workspace/dotfiles`.

### Edit a dotfile

The files under `~` are symlinks into `home/`. Edit either path, then commit in
this repository.

### Add a dotfile

Move the file to the same path under `home/`, stage it, and link it. The links
cover only files that Git tracks, so run `git add` before `link`.

```sh
mv ~/.foorc ~/Workspace/dotfiles/home/.foorc
git add home/.foorc
mise run link
```

### Remove a dotfile

```sh
git rm home/.foorc
mise dot apply --prune
```

`--prune` removes the links whose source is gone.

### Directories linked whole

`~/.config/ghostty`, `git`, `karabiner`, `nvim`, `sheldon`, `wezterm` and `zed`
are each one symlink to the whole directory instead of one link per file.
git, zed and karabiner save a file by replacing it, which turns a per-file link
into a regular file; nvim is a separate clone. To link another directory whole,
add it to the `exclude` list of `[dotfile_groups.home]` and add an entry under
`[dotfiles]` in `home/.config/mise/config.toml`.

### Packages and tools

| To add | Put it in | Then run |
|---|---|---|
| A language or CLI from mise | `[tools]` in `home/.config/mise/config.toml`, or run `mise use -g <tool>` | `mise run tools` |
| A Homebrew formula | `"brew:<name>" = { os = "macos" }` under `[bootstrap.packages]` | `mise run packages` |
| An App Store app | `"mas:<id>" = { os = "macos" }` under `[bootstrap.packages]` | `mise run packages` |
| A GUI app or font | `cask "<name>"` in `script/Brewfile` | `mise run casks` |

Deleting a line does not uninstall the package. Uninstall it with
`brew uninstall <name>` or `mise uninstall <tool>`.

Do not run `mise bootstrap packages prune`. Some formulae on this machine are
not declared yet, and `prune` would remove them.

### Upgrades

Give each package one owner, so that two updaters never replace the same files:

| Packages | Upgraded by |
|---|---|
| GUI apps with a built-in updater (most casks) | The app itself |
| App Store apps | The App Store |
| Coding agent CLIs: `codex`, `claude`, `agy`, `grok` | mise's `tool-update` LaunchAgent, every hour (`auto_update = "1h"`), with no minimum release age |
| Other CLIs that update themselves | The CLI itself. Keep them out of the Brewfile. |
| mise itself | `mise self-update` |
| mise tools and Homebrew formulae | `mise run upgrade` |
| Casks without an updater (fonts, `git-credential-manager`, `wezterm`) | `brew upgrade --cask <name>` |
| Neovim plugins | `mise run nvim`, then commit `lazy-lock.json` in nvimrc |
| Agent skills and herdr plugins | `mise run agents` |

`mise run casks` runs `brew bundle`, which also upgrades outdated casks and can
quit apps that are running.

### Neovim config

Edit `~/.config/nvim` and commit in that directory: it is the nvimrc
repository, not this one. `mise run nvim` pulls nvimrc with `--ff-only` and
fails if the local copy has diverged.

### Check for drift

```sh
mise dot status                           # dotfile links
mise bootstrap packages status            # formulae and App Store apps
brew bundle check --file=script/Brewfile  # casks
```

## Tasks

| Task | What it does |
|---|---|
| `setup` | Runs the eight tasks above, in order. |
| `link` / `unlink` | Creates or removes the dotfile links. |
| `upgrade` | Upgrades the mise tools and the Homebrew formulae. |
| `nvim-clone` | Clones nvimrc if it is missing. `link` and `nvim` run it first. |

`mise tasks` lists every task with its description.

## Not in this repository

- Secrets. The repository is public, so keep tokens and keys in files that Git
  does not track.
- The Claude Code and Codex configs (`~/.claude/settings.json`,
  `~/.claude.json`, `~/.codex/config.toml`). The apps rewrite them with
  machine-local state.
- mise's record of the links it created, in `~/.local/state/mise`. Keep that
  directory: `unlink` and `--prune` depend on it.
