# my-nix-config

Personal NixOS + home-manager config, scaffolded from the [nix-dendritic](https://github.com/cgubbin/nix-dendritic) starter and built with the dendritic pattern via [flake-file](https://github.com/denful/flake-file).

This repo depends on the starter as a flake input. Nothing here should duplicate what the starter already provides — this repo only holds what's specific to *you*: identity, hostnames, secrets, and your own opinionated extras. 

## Setting up this config

Delete this section once you've finished it — everything below is a one-time walkthrough for a freshly-instantiated repo, not ongoing documentation. Replace it afterward with real notes about *this* machine: what it's for, anything host-specific worth remembering, how to redeploy it.

## 0. Instantiate the template

In a new, empty directory (not inside the starter repo):
```bash
mkdir my-nix-config && cd my-nix-config
nix flake init -t github:cgubbin/nix-dendritic#personal
```

## 1. Initialize git and stage everything

```bash
git init
git add -A
```
This isn't optional bureaucracy — **flakes only see files tracked by git** (staged is enough, committed isn't required). Any file you add, rename, or edit later in this walkthrough needs `git add -A` again before Nix will notice it exists. This is the single most common source of "why isn't my change taking effect" throughout the steps below.

## 2. Name your host

```bash
git mv modules/hosts/myhost.nix modules/hosts/<hostname>.nix
```
Edit the renamed file replaced each `<hostname>`. This is the complete shape, including secrets wiring (step 6 below explains each piece) — fill in the placeholders as you go, or leave the secrets parts for later and come back once you've done step 6.

## 3. Name your user

```bash
git mv modules/users/myuser.nix modules/users/<username>.nix
git mv home/myuser home/<username>
```
Edit `modules/users/<username>.nix`, replacing every `"<username>"` string and the `home/<username>` path in its `import-tree` call.

Udate the repo:
```bash
git add -A
```

## 4. Set your git identity

Edit `home/<username>/git.nix` (identity is personal, non-shareable content, so it belongs under `home/`, not `modules/` — no separate import step needed, `import-tree` picks it up automatically):
```nix
{...}: {
  programs.git.settings = {
    user = {
      name = "<your name or github username>";
      email = "<your email>";
    };
    github.user = "<your github username>";
  };
}
```
This merges cleanly with the starter's own `git.nix` config (delta, aliases, rebase-on-pull — already pulled in via `inputs.starter.modules.homeManager.git` in step 3) as long as neither file sets the exact same option twice.

## 5. Add packages
- Personal, one-off tools with no config of their own → `home/<username>/packages.nix`, in `home.packages`.
- A tool with actual config (dotfiles, program options) → its own file under `home/<username>/`.
- Generic enough that a stranger deploying the starter would also want it → belongs in the **starter**, not here.

No import step needed for anything under `home/<username>/` — it's picked up automatically by the `import-tree` call in step 3. Remember `git add -A` after creating new files.

## 6. Set up secrets (sops)
**6a. Create a private `nix-secrets` repo** (a plain repo, not a flake):
```
secrets/
  <hostname>.yaml
  <hostname>-user.yaml
.sops.yaml
```

**6b. Generate age keys** 

```bash
sudo mkdir -p /var/lib/sops-nix
sudo age-keygen -o /var/lib/sops-nix/key.txt      # system key
age-keygen -y /var/lib/sops-nix/key.txt            # prints its public key — copy it

mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt          # user key
age-keygen -y ~/.config/sops/age/keys.txt          # prints its public key — copy it
```

**6c. Add both public keys to `nix-secrets/sops.yaml`
```{bash}
keys:
  - &<hostname>_system age1...   # the /var/lib/sops-nix/key.txt public key
  - &<hostname>_user   age1...   # the ~/.config/sops/age/keys.txt public key

creation_rules:
  - path_regex: secrets/<hostname>-system\.yaml$
    key_groups:
      - age:
          - *<hostname>_system

  - path_regex: secrets/<hostname>-user\.yaml$
    key_groups:
      - age:
          - *<hostname>_user
```

**6d. Set your login password as a secret** — never store the plaintext:
```bash
nix shell nixpkgs#whois -c mkpasswd -m sha-512
```
Add the result to `secrets/<hostname>.yaml`:
```bash
nix shell nixpkgs#sops -c sops secrets/<hostname>.yaml
```
```yaml
<username>-password: $6$...
```

**6e. Confirm the wiring** — this should already be in place if you filled in `modules/hosts/<hostname>.nix` fully back in step 2 (the `sops = inputs.starter.lib.mkSopsHost { ... }` block, the `nix-secrets` input with `flake = false;`, and `mkSopsPasswordUser` in the `imports` list). `mkSopsPasswordUser` also sets `users.mutableUsers = false;` as part of what it does — required for the password to actually apply on a rebuild, not only at first account creation.

**6f. First-time regeneration gotcha:** if `nix run .#write-flake` fails trying to fetch `nix-secrets` as a flake *after* you've already added `flake = false`, the already-generated `flake.nix` is stale and needs a one-time manual edit (add `flake = false` to its `nix-secrets` block by hand) before `write-flake` can regenerate correctly on its own.

**6g. Verify the hash before switching, not after:**
Although wsl does not ask for a login password, its smart to check before finalising.
```bash
stored=$(sudo cat /run/secrets-for-users/<username>-password)
nix shell nixpkgs#whois -c mkpasswd -m sha-512 -S "$(echo "$stored" | awk -F'$' '{print $(NF-1)}')"
# compare output to $stored

**6h. Setup `.netrc` for access to cloudsmith:**
Run:
```{bash}
nix shell nixpkgs#sops -c sops secrets/<hostname>-user.yaml
```
And in the corresponding editor write:
```{yaml}
netrc: |
  machine <host> login <username> password <token-or-password>
```


```

## 7. Optional: shell setup (fish, etc.)

Fish as your *actual* login shell can break POSIX-dependent tooling (rescue shells, some scripts). The safer route — bash stays the login shell, fish launches automatically for interactive sessions:
```nix
# home/<username>/shell.nix
{pkgs, ...}: {
  programs.bash.initExtra = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" ]]; then
      exec ${pkgs.fish}/bin/fish
    fi
  '';
}
```
(`initExtra`, not `interactiveShellInit` — that name only exists at the NixOS system level, not inside home-manager's `programs.bash`.)

## 8. Unfree packages

Already scaffolded in `modules/hosts/<hostname>.nix` from step 2 (`nixpkgs.config.allowUnfreePredicate` + `home-manager.useGlobalPkgs = true;`) — the starter never allows unfree packages globally, so this is where that consent decision lives. Add package names to the predicate's list as you hit "refusing to evaluate ... unfree" errors going forward; there's no way to know the full list in advance.

## 9. Build and switch

```bash
nix run .#write-flake
nix flake check
sudo nixos-rebuild build --flake .#<hostname>    # cheapest final check, no activation
sudo nixos-rebuild test --flake .#<hostname>     # activates, but not the boot default
```
```bash
sudo nixos-rebuild switch --flake .#<hostname>   # take the plunge
git add -A && git commit -m "initial personal config"
```

## 10. Later: pulling starter updates

```bash
nix flake update starter
git diff flake.lock   # review what actually changed before committing
git add -A && git commit -m "bump starter"
```
