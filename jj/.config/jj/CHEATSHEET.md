# jj Cheatsheet

> Aliases: shell aliases from `.bashrc`/`.zshrc`, jj aliases from `config.toml`

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
jj bookmark advance       # jj b a — move bookmark onto @-
jp                         # push
```

---

## Bookmarks (= Git Branches)

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| List bookmarks | `jj bookmark list` | — | `git branch -a` |
| Create bookmark | `jj bookmark create <name> -r @-` | — | `git branch <name>` |
| Advance nearest bookmark to `@` | `jj bookmark advance` | `jj b a` | — |
| Move bookmark to specific rev | `jj bookmark move <name> --to <rev>` | — | `git branch -f <name> <sha>` |
| Delete bookmark | `jj bookmark delete <name>` | — | `git branch -d <name>` |
| Start work on a remote branch | `jf` then `jj new <name>` | — | `git fetch && git checkout -t origin/<name>` |

Remote bookmarks auto-track on fetch (`auto-track-bookmarks = "*"` in
`config.toml`), so `jf` + `jj new <name>` is all you need — no separate
tracking step.

### Typical "start new feature" workflow

```sh
jfnm                          # fetch + new change on top of main
# edit files
jc -m "feat: ..."
jj bookmark create my-feature -r @-
jj bookmark advance           # jj b a
jp                            # push
```

---

## Sync with Remote

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| Fetch from origin | `jj git fetch` | `jf` | `git fetch` |
| Fetch + start on main | `jj git fetch && jj new main` | `jfnm` | `git pull origin main && git switch -c <branch>` |
| Push current bookmark | `jj git push` | `jp` | `git push` |
| Advance bookmark + push | `jj bookmark advance && jj git push` | `jj b a && jp` | `git push` (after commit) |
| Rebase onto trunk | `jj rebase -d main` (or `master`) | — | `git rebase origin/main` |

---

## Rewrite History

| situation | jj | alias | git equivalent |
|-----------|----|----|----------------|
| Squash into parent | `jj squash` | — | `git commit --amend` (roughly) |
| Squash specific rev into parent | `jj squash -r <rev>` | — | `git rebase -i` → fixup |
| Squash interactively (pick hunks) | `jj squash -i` | — | `git add -p && git commit --amend` |
| Rebase onto different parent | `jj rebase -d <rev>` | — | `git rebase <rev>` |
| Rebase onto trunk | `jj rebase -d main` (or `master`) | — | `git rebase origin/main` |
| Abandon (drop) a change | `jj abandon <rev>` | — | `git rebase -i` → drop |
| Undo last operation | `jj undo` | — | `git reflog` + `git reset` |

Squashing a whole feature branch into one commit isn't part of the workflow
— PRs get squash-merged by GitHub/GitLab anyway. `jj squash -i` covers the
rare case of moving specific changes by hand.

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

**Why `@` is always empty after `jj commit`:**
`jj commit` snapshots `@` into a real commit and opens a fresh empty `@` on top. This is normal — edit files, then `jc` again.
