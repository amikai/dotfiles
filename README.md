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
| `script/agents.sh` | The helper that the `agents` task runs. |
| `bootstrap.sh` | The entry point for a new Mac. |

The Neovim config is a separate repository,
[amikai/nvimrc](https://github.com/amikai/nvimrc), cloned straight into
`~/.config/nvim` through `[bootstrap.repos]` in the global mise config.

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
Sign in to the App Store first: `packages` installs App Store apps, and paid
apps must already be purchased.

`bootstrap.sh` installs Homebrew (for the casks) if it is missing, installs
mise to `~/.local/bin` with its [official installer](https://mise.jdx.dev/installing-mise.html)
if it is missing, trusts `mise.toml`, and runs `mise run setup`. The `setup` task runs these tasks in
order:

1. `packages`: Homebrew formulae and App Store apps from `[bootstrap.packages]`.
2. `link`: links `home/` into `~`.
3. `login-shell`: makes Homebrew's zsh the login shell.
4. `tools`: the mise `[tools]`, such as languages, CLIs and language servers.
5. `services`: the LaunchAgent that updates the coding agent CLIs every hour.
6. `nvim`: clones or fast-forwards nvimrc, then syncs its plugins.
7. `agents`: installs agent skills and the herdr integrations.
8. `casks`: installs the casks in `script/Brewfile` that are missing. It runs
   last, so a failing cask does not block the rest.

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
cover only files that Git tracks, so run `git add` before `link`. The
directories linked whole (below) are the exception: everything in them shows
up, tracked or not.

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

`~/.config/ghostty`, `git`, `karabiner`, `sheldon`, `wezterm` and `zed`
are each one symlink to the whole directory instead of one link per file.
git, zed and karabiner save a file by replacing it, which turns a per-file link
into a regular file. To link another directory whole,
add an entry under `[dotfile_groups.home.entries]` in
`home/.config/mise/config.toml`.

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
| Coding agent CLIs: `codex`, `claude`, `agy`, `grok`, `pi` | mise's `tool-update` LaunchAgent, every hour (`auto_update = "1h"`), with no minimum release age. After each pi install, `pi update --extensions` refreshes its extensions. |
| Other CLIs that update themselves | The CLI itself. Keep them out of the Brewfile. |
| mise itself | `mise self-update` |
| mise tools and Homebrew formulae | `mise run upgrade` |
| Casks without an updater (fonts, `git-credential-manager`, `wezterm`) | `brew upgrade --cask <name>` |
| Neovim plugins | `mise run nvim`, then commit `lazy-lock.json` in nvimrc |
| Agent skills and herdr plugins | `mise run agents` |

`mise run casks` only installs missing casks (`brew bundle install --no-upgrade`),
so it never quits a running app to upgrade it.

### Neovim config

`~/.config/nvim` is the nvimrc repository itself: edit it and commit there.
`mise run nvim` fast-forwards it, but skips it while it has local changes, so
commit `lazy-lock.json` after a plugin sync or the config stops updating.

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

`mise tasks` lists every task with its description.

## Not in this repository

- Secrets. The repository is public, so keep tokens and keys in files that Git
  does not track.
- The Claude Code and Codex configs (`~/.claude/settings.json`,
  `~/.claude.json`, `~/.codex/config.toml`). The apps rewrite them with
  machine-local state.
- mise's record of the links it created, in `~/.local/state/mise`. Keep that
  directory: `unlink` and `--prune` depend on it.
