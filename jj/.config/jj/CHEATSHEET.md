# jj Cheatsheet

> Aliases: shell aliases from `.zshrc`, jj aliases from `config.toml`

---

## Inspect

| jj | alias | git equivalent |
|----|-------|----------------|
| `jj status` | `js` | `git status` |
| `jj diff` | `jd` | `git diff` |
| `jj diff --from @-` | — | `git diff HEAD~1` |
| `jj log` | — | `git log --oneline --graph` |
| `jj log -r all() -n 10` | `jj lr` | `git l -10` (`lr`) |
| `jj show` | — | `git show HEAD` |
| `jj show <rev>` | — | `git show <sha>` |

---

## Make Changes

In jj, `@` is always the working copy. You don't stage — you just edit files and describe/commit.

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| See what changed | `jj status` | `js` | `git status` |
| Commit working copy | `jj commit -m "..."` | `jc -m "..."` | `git add -A && git commit -m "..."` |
| Amend commit message | `jj describe -m "..."` | — | `git commit --amend -m "..."` |
| Amend commit contents | edit files, then `jj squash` | — | `git add -A && git commit --amend` |
| Start new empty change | `jj new` | `jn` | `git switch -c <branch>` (roughly) |
| Go back and edit old commit | `jj edit <rev>` | — | `git rebase -i` → edit |

### Typical workflow

```sh
# edit files
jc -m "feat: add thing"   # commit, @ is now empty
jj up                     # move bookmark to @-, push
```

---

## Bookmarks (= Git Branches)

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| List bookmarks | `jj bookmark list` | — | `git branch -a` |
| Create bookmark | `jj bookmark create <name> -r @-` | — | `git branch <name>` |
| Move bookmark to current commit | `jj tug` | — | — |
| Move bookmark to specific rev | `jj bookmark move <name> --to <rev>` | — | `git branch -f <name> <sha>` |
| Delete bookmark | `jj bookmark delete <name>` | — | `git branch -d <name>` |
| Checkout remote branch | `jj checkout <name>` | — | `git checkout -t origin/<name>` |
| Checkout remote branch (legacy alias) | `jj co-br <name>` | — | same |

---

## Sync with Remote

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| Fetch from origin | `jj git fetch` | `jf` | `git fetch` |
| Fetch + start on main | `jj git fetch && jj new main` | `jfnm` | `git pull origin main && git switch -c <branch>` |
| Push current bookmark | `jj git push` | `jp` | `git push` |
| Move bookmark + push | `jj up` | — | `git push` (after commit) |
| Rebase onto trunk | `jj retrunk` | `jrt` | `git rebase origin/main` |

### Typical "start new feature" workflow

```sh
jfnm                          # fetch + new change on top of main
# edit files
jc -m "feat: ..."
jj bookmark create my-feature -r @-
jj up                         # move bookmark + push
```

---

## Rewrite History

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| Squash into parent | `jj squash` | — | `git commit --amend` (roughly) |
| Squash specific rev into parent | `jj squash -r <rev>` | — | `git rebase -i` → fixup |
| Squash whole branch into one commit | `jj collapse` | — | `git rebase -i` → squash all |
| Rebase onto different parent | `jj rebase -d <rev>` | — | `git rebase <rev>` |
| Rebase onto trunk | `jj retrunk` | `jrt` | `git rebase origin/main` |
| Abandon (drop) a change | `jj abandon <rev>` | — | `git rebase -i` → drop |
| Undo last operation | `jj undo` | — | `git reflog` + `git reset` |

---

## Conflicts

| situation | jj | git equivalent |
|-----------|-----|----------------|
| See conflicted files | `jj status` | `git status` |
| Resolve interactively | `jj resolve` | `git mergetool` |
| Mark resolved (manual edit) | `jj squash` after editing | `git add <file>` |

---

## Key Concepts

**`@`** — working copy (always exists, auto-tracks file changes)  
**`@-`** — parent of working copy (the last real commit)  
**`trunk()`** — most recent `main`/`master` on a remote  
**`closest_bookmark(@-)`** — nearest ancestor commit that has a bookmark  

**Why `@` is always empty after `jj commit`:**  
`jj commit` snapshots `@` into a real commit and opens a fresh empty `@` on top. This is normal — edit files, then `jc` again.
