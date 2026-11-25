# Contributing to Piraeus

Piraeus consists of several repositories in the [`piraeusdatastore`](https://github.com/piraeusdatastore) GitHub organization.
You can contribute by reporting issues, improving documentation, fixing bugs, or adding features.
The [code of conduct](./CODE_OF_CONDUCT.md) describes how contributors are expected to behave in the Piraeus community.

## Reporting issues

Open an issue in the repository of the affected component, for example to:

- Report a bug or a performance problem.
- Request or propose a feature.
- Report missing or incorrect documentation.
- Ask a question about the project.

Remove sensitive data from the issue description and from any logs you attach.
Sensitive data includes passwords, secret keys, network locations, and private business data.

## Code and documentation contributions

Submit code and documentation changes as pull requests on GitHub.
Pull requests can fix bugs or typos, add missing tests, improve features, remove unused code, refactor code, or correct documentation.

## Contribution workflow

Piraeus follows the "Fork and Pull Request" workflow on GitHub.
[GitHub Docs](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project) describe how to create a fork and open a pull request.

The sections [Commits](#commits), [Changelog](#changelog), and [Pull request review](#pull-request-review) apply to all Piraeus repositories.
A repository can have its own `CONTRIBUTING.md` file that describes the target branch, development tools, tests, and other details specific to that repository.
If a repository guide differs from this guide, follow the repository guide.

Before you work on a larger change, open an issue to discuss it.

Rebase your branch onto the target branch with [`git rebase`](https://git-scm.com/book/en/v2/Git-Branching-Rebasing).
Do not merge the target branch into your branch.

After you open a pull request, a [maintainer](./MAINTAINERS.md) reviews the changes.
The maintainer either requests changes or approves the pull request.
After approval, the maintainer merges the pull request.

## Commits

* Limit each commit to one logical change, including the files generated for it.
* Each commit must build and pass the tests.
  If a commit does not build, `git bisect` cannot test it.
* Do not combine refactoring, formatting changes, and functional changes in one commit.

### Commit messages

* Write the subject line in the imperative mood, for example `Add option to set the replica count`.
  Do not end it with a period.
* Limit the subject line to about 50 characters.
  A prefix is not required.
* Separate the body from the subject line with a blank line.
* Wrap the body at 80 characters.
* In the body, describe why the change is necessary and what it changes.
  Leave out details that the diff shows.
* Do not reference GitHub issues or pull requests, for example `Fixes #123`.
  Link them in the pull request description instead.

```
Add option to set the replica count

The replica count was fixed at 2. Clusters with more than two nodes
could not use additional replicas for redundancy.

Signed-off-by: Random J Developer <random@developer.example.org>
```

### Developer Certificate of Origin

Piraeus uses the [Developer Certificate of Origin](https://developercertificate.org/).
With it, you certify that the changes in a pull request are your own, or that you have the right to share them.
Add a `Signed-off-by` line with your name and email address to every commit.
The `-s` flag of `git commit` adds the line:

```
$ git commit -s -m 'Add option to set the replica count'
```

## Changelog

Repositories with a `CHANGELOG.md` file follow the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

* For every change that affects users, add an entry under `[Unreleased]`, in the matching subsection: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, or `Security`.
* Describe the effect on the user in one or two lines.
  Do not describe the implementation.
* Add the entry in the same pull request as the change.
* Do not add an entry for changes to documentation, CI, or tests.
* If users must take an action during an upgrade, state the action in the entry.
  The repository guide describes where to document the upgrade steps in detail.

```
## [Unreleased]

### Added

- Option to set the replica count for new volumes.

### Fixed

- Volumes no longer stay in `Pending` after a node restart.
```

## Pull request review

### Opening a pull request

* In the description, explain what the pull request changes and why.
  Link the related issue.
* Limit a pull request to one topic.
  Open separate pull requests for unrelated changes.
* Mark a pull request that is not ready for review as a draft.

### Addressing review comments

* Reply to every review comment with the change you made, or with the reason you did not make a change.
* Fold follow-up fixes into the commits that introduced the problem.
  Do not add separate commits that address review comments.
* Do not apply suggestions with the GitHub web interface.
  GitHub creates a separate commit without a `Signed-off-by` line.
  Apply the suggestion locally and fold it into the matching commit.

To fold a fix into an existing commit, create a fixup commit, squash it into its target, and update the pull request:

```
$ git commit -s --fixup=<commit>
$ git rebase -i --autosquash <commit>~
$ git push --force-with-lease
```

After you push the changes, request a new review from the reviewer.

## Other ways to contribute

Piraeus development takes place on GitHub.
Besides pull requests, you can contribute by:

- Answering questions in issues.
- Reviewing pull requests from other contributors.
- Writing about Piraeus outside of GitHub, for example in blog posts.

## Joining the Piraeus team

Contributors who take part in the community regularly can join the Piraeus team.

### Requirements

- Read this contributing guide.
- Read the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).
- Submit several pull requests.
- Take part in the community, for example by:
    - Opening or commenting on issues.
    - Submitting pull requests.
    - Reviewing pull requests.

### Applying

Apply in one of two ways:

- Open a pull request in this repository.
- Contact the team through the [community](./README.md#community) channels.
