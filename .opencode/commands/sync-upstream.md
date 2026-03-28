---
description: Sync fork with upstream repo
---

Sync this fork with the upstream repo by fetching from upstream, rebasing local commits on top of upstream/main, and force-pushing the result to origin.

Steps:
1. Run `git fetch upstream`
2. Check if there are new upstream commits with `git log --oneline HEAD..upstream/main | head -20`
3. If there are new commits, run `git rebase upstream/main`
4. If the rebase succeeds, run `git push --force-with-lease origin main`
5. Report a summary of how many commits were synced and whether the push succeeded

If the rebase fails with conflicts, stop and report the conflicts to the user so they can resolve them manually.
