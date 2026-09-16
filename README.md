# nix-template

A NixOS + home-manager starter, built with [flake-file](https://github.com/denful/flake-file). Every piece of configuration is a `flake-parts` module, auto-discovered from the directory tree — there's no central `inputs`/`outputs` block to maintain by hand.

This repo is a **library**, meant to be depended on, not forked. Deploy your own machine by scaffolding a small **personal repo** from the included template (see [Quick start](#quick-start)) — never edit this repo's files directly for your own machine's config.

## Why dendritic?

In a traditional flake, every new tool, every new host, and every new input touches the same monolithic `flake.nix`. That file grows without bound and every change risks breaking something unrelated.

In this pattern:
- **Every file is a self-contained feature.** A feature that needs an input declares that input right there, in the same file as the config that uses it — no separate `inputs.nix` to keep in sync.
- **Files are auto-imported.** [`import-tree`](https://github.com/vic/import-tree) walks `modules/` recursively; dropping a new file in is enough, no manual `imports = [ ... ]` list.
- **Removing a feature removes everything it added** — its input, its config, its packages — because they all lived in one file.
- **flake-file** ([denful/flake-file](https://github.com/denful/flake-file)) generates the static `flake.nix` from these modules, so the restrictive, non-programmable native flake syntax is never hand-written.

## Repo layout

```
modules/
  dendritic.nix           # bootstrap: flake-parts "modules" extension + import-tree
  lib-option.nix          # declares flake.lib as a mergeable option (see "Gotchas")
  templates.nix           # exposes the `personal` template (nix flake init -t)

  nixpkgs.nix              # nixpkgs input + systems list
  formatting.nix           # nixfmt formatter
  git-hooks.nix            # git-hooks-nix input + pre-commit hooks
  devshell.nix             # dev shell (just, home-manager, pre-commit hooks)

  nix-index.nix            # nix-index-database — simple aspect
  home-manager.nix         # home-manager input + nixos-level wiring + extraSpecialArgs
  sops.nix                 # sops-nix — multi-context aspect + mkSopsHost/mkSopsPasswordUser factories
  wsl.nix                  # nixos-wsl — simple aspect
  native.nix               # systemd-boot native config — simple aspect
  system-base.nix          # inheritance aspect: bundles nix-index + home-manager + sops

  git.nix                  # generic (identity-free) git configuration, nixos+homeManager
  claude-code.nix          # llm-agents.nix — Claude Code, nixos+homeManager
  cli-tools.nix            # shared bag of no-config CLI tools
  cloud-tools.nix          # cloud/infra CLI tools (terraform, etc — unfree)

  lib/
    mk-host.nix             # factory: assembles a full nixosConfiguration

templates/
  personal/                # scaffold copied by `nix flake init -t ...#personal`
    README.md               # becomes the new repo's own README — full setup walkthrough,
                              # meant to be trimmed down to real notes once followed
    modules/
      personal.nix
      hosts/myhost.nix
      users/myuser.nix
    home/myuser/git.nix
```

## Quick start

Deploying your own machine from this starter — **do this in a new, separate repo**, never inside this one:

```bash
mkdir my-nix-config && cd my-nix-config
nix flake init -t github:cgubbin/nix-dendritic#personal
git init && git add -A
```

The template copies its own `README.md` into your new repo — open it and follow the walkthrough. It covers naming your host/user, setting git identity, adding packages, configuring sops secrets, and building, and it's meant to be replaced with real notes about your own machine once you're done with it. (The one-line message `nix flake init` prints to the terminal is just a pointer to this file, not the instructions themselves — the file is what persists.)

## The starter/personal split

This is the load-bearing design decision in the whole repo, so it's worth being explicit:

- **This repo (the starter)** contains only generic, shareable config. Nothing here should ever contain a real username, email, hostname, or `stateVersion` — those are per-deployment facts, not shared features.
- **Your personal repo** depends on this one as a flake input (`flake-file.inputs.starter.url = "github:cgubbin/nix-dendritic";`) and adds identity, secrets config, and your own opinionated extras.
- Changes to this flake are mirrored by **updating** this one through `nix flake update starter` in your personal repo, followed by reviewing the `flake.lock` diff — an explicit, reviewable step, never a silent merge.
