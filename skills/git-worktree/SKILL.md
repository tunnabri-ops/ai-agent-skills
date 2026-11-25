---
name: git-worktree
description: Use when working on several branches at the same time, running parallel tasks or agents in one repository, switching branches without stashing or losing uncommitted work, or cleaning up extra checkouts after a merge.
---

# Git Worktree

Work on multiple branches in parallel without switching, stashing, or
clobbering uncommitted changes. One worktree is one checked-out branch in
its own directory; all worktrees share the same `.git` objects, history,
and remotes, so a commit made in any worktree is visible from all of them.

## Core Rules

- One branch per worktree. Git refuses to check out the same branch in two
  worktrees at once; that refusal is a safety feature, not an error to
  work around.
- Never run `git worktree add` inside another worktree. Create worktrees
  from the main checkout, or from any directory, using absolute paths.
- Keep the main worktree clean and on the default branch (`main` or
  `master`). Treat it as the stable home base, not a place for experiments.
- A worktree is a full checkout, not a copy: it has its own working files,
  its own index, and its own HEAD, but it shares branches, tags, stashes,
  and the object database with every other worktree.
- Untracked files, ignored files, and installed dependencies are per
  worktree. A `node_modules` folder or a `.env` file in one worktree does
  not appear in another; install and configure each worktree separately.
- Remove a worktree when its branch is merged or abandoned. A forgotten
  worktree leaves a stale branch, a stale directory, and a confusing
  `git worktree list`.

## Workflow

1. Check the current state before adding anything. Run `git status` and
   `git worktree list` in the main checkout so you know which branches
   are already checked out and where.
2. Fetch the latest history first: `git fetch origin`. A worktree created
   from a stale remote branch starts from stale code.
3. Create a worktree for a new branch with `-b`, giving the path first
   and the branch second:

   ```bash
   git worktree add ../my-app-auth -b feature/auth
   cd ../my-app-auth
   ```

   The path `../my-app-auth` sits beside the main checkout, not inside it.
4. Create a worktree for an existing branch by naming the branch without
   `-b`:

   ```bash
   git worktree add ../my-app-fix bugfix/login-crash
   ```

   If the branch is already checked out elsewhere, Git prints an error
   naming the other worktree. Pick a different branch or remove the
   other worktree first.
5. Work normally inside the new directory: edit, test, commit, and push.
   Commands such as `git status`, `git log`, and `git push` behave exactly
   as they do in a normal checkout.
6. Keep the branch up to date. From inside the worktree, run
   `git fetch origin` and then `git rebase origin/main` (or
   `git merge origin/main`) so the worktree does not drift far from main.
7. Merge back from the main worktree. Do not merge a worktree into itself;
   switch to the main checkout and merge the finished branch there:

   ```bash
   cd ../my-app            # the main worktree
   git checkout main
   git pull origin main
   git merge feature/auth
   git push origin main
   ```

8. Remove the worktree after the merge, then delete the branch if it is
   no longer needed:

   ```bash
   git worktree remove ../my-app-auth
   git branch -d feature/auth
   ```

9. Prune stale metadata when a worktree directory was deleted by hand
   (with `rm -rf`) instead of with `git worktree remove`:

   ```bash
   git worktree prune
   git worktree list
   ```

## Common Commands

| Task | Command |
|------|---------|
| List all worktrees | `git worktree list` |
| List with branch and HEAD | `git worktree list --verbose` |
| Add a new branch | `git worktree add <path> -b <branch>` |
| Add an existing branch | `git worktree add <path> <branch>` |
| Add a detached HEAD | `git worktree add --detach <path> <commit>` |
| Move a worktree | `git worktree move <old-path> <new-path>` |
| Lock a worktree | `git worktree lock <path>` |
| Remove a worktree | `git worktree remove <path>` |
| Force-remove a dirty worktree | `git worktree remove --force <path>` |
| Prune stale entries | `git worktree prune` |

## Examples

Example 1 — two features in parallel:

```bash
git worktree list
# /home/user/my-app        abc1234 [main]
git worktree add ../my-app-search -b feature/search
git worktree add ../my-app-billing -b feature/billing
git worktree list
# /home/user/my-app          abc1234 [main]
# /home/user/my-app-search   abc1234 [feature/search]
# /home/user/my-app-billing  abc1234 [feature/billing]
```

Input: the user asks to build search and billing at the same time.
Output: two independent directories, each on its own branch, with the
main checkout untouched on `main`.

Example 2 — review a pull-request branch without disturbing current work:

```bash
git fetch origin pull/42/head:pr-42
git worktree add ../my-app-pr42 pr-42
cd ../my-app-pr42 && npm test
```

Input: review PR #42 while uncommitted changes sit in the main checkout.
Output: the PR code runs and tests in its own directory; the main
checkout's dirty files are never stashed or touched.

Example 3 — fix a hotfix while a feature is half done:

```bash
cd ../my-app              # main worktree, feature branch is dirty
git worktree add ../my-app-hotfix -b hotfix/crash
cd ../my-app-hotfix
# fix, commit, push, merge hotfix/crash into main
git worktree remove ../my-app-hotfix
cd ../my-app && git checkout feature/search   # resume where you left off
```

## Detached HEAD Warning

`git worktree add --detach <path> <commit>` checks out a commit, not a
branch. Commits made in a detached worktree belong to no branch and are
easy to lose: the worktree can be pruned and the commits garbage-collected
with no branch pointing at them. Use detached mode only to inspect an old
commit or to run a one-off test, never to do real work. If you already
made commits while detached, save them immediately:

```bash
git branch rescue/detached-work <commit-or-HEAD>
git checkout rescue/detached-work
```

## Checklist

- [ ] Ran `git worktree list` before adding, to avoid duplicating a branch.
- [ ] Fetched from origin before creating the worktree.
- [ ] Used `-b` for a new branch and no `-b` for an existing branch.
- [ ] Created the worktree beside the main checkout, not inside it.
- [ ] Installed dependencies and copied needed local config (`.env`) in
  the new worktree.
- [ ] Merged from the main worktree, not from inside the feature worktree.
- [ ] Ran `git worktree remove` after merging, and `git branch -d` for
  the finished branch.
- [ ] Ran `git worktree prune` if any worktree directory was deleted by hand.

## Pitfalls

- Do not check out the same branch in two worktrees; Git blocks it, and
  forcing it with `--force` corrupts the index for that branch.
- Do not create a worktree inside another worktree or inside `.git`;
  nested checkouts confuse tooling, editors, and `git worktree list`.
- Do not run `git worktree remove` on a worktree with uncommitted work
  unless you mean to lose it; `--force` discards those changes silently.
- Do not assume a commit in one worktree is pushed; each worktree pushes
  its own branch, and `git push` in the main checkout does not push
  other worktrees' branches.
- Do not leave a detached-HEAD worktree around after testing; either
  create a branch from it or remove it the same day.
- Do not share one `.env` or one database file between worktrees by
  symlinking; parallel test runs will overwrite each other's data.
- Do not forget `git worktree prune` after deleting a directory manually;
  the stale entry keeps the branch locked until it is pruned.
