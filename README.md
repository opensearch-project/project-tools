- [OpenSearch Project Tools](#opensearch-project-tools)
  - [Usage](#usage)
    - [Installation](#installation)
    - [Global Options](#global-options)
      - [Tokens](#tokens)
      - [Quiet](#quiet)
      - [Caching](#caching)
      - [Debug Logging](#debug-logging)
    - [Org Info](#org-info)
    - [Org Members](#org-members)
    - [Sorted List of Repos](#sorted-list-of-repos)
    - [Org Teams](#org-teams)
    - [Code Owners](#code-owners)
    - [Maintainers](#maintainers)
    - [Contributor Stats](#contributor-stats)
    - [Contributor Lists](#contributor-lists)
    - [Pull Requests](#pull-requests)
    - [Pull Request Stats](#pull-request-stats)
    - [Issues](#issues)
    - [Member Bios](#member-bios)
    - [DCO Signers](#dco-signers)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [Security](#security)
- [License](#license)
- [Copyright](#copyright)

## OpenSearch Project Tools

[![Tests](https://github.com/opensearch-project/project-tools/actions/workflows/test.yml/badge.svg)](https://github.com/opensearch-project/project-tools/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/opensearch-project/project-tools/branch/main/graph/badge.svg)](https://codecov.io/gh/opensearch-project/project-tools)

Tools to gather stats on a GitHub organization.

### Usage

#### Installation

1. Clone the repository locally on your desktop.
1. Install Ruby 2.7 or newer. We recommend using [RVM](https://rvm.io/).
1. Install bundler with `gem install bundler`.
1. Run `bundle install`.

#### Global Options

##### Tokens

Set `GITHUB_API_TOKEN` to a personal access token (PAT) or with `--token` to avoid running into too many rate-limit requests as authenticated requests get a higher rate limit. See [GitHub rate limiting](https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting) for more information.

##### Quiet

Use `-q` or `--quiet` to remove progress bars.

##### Caching

The tool will cache data into `.cache` by default for all GitHub API queries to avoid making duplicate requests. To disable caching use `--no-cache`. Run with `--debug` to display cache hits and misses.

##### Debug Logging

Use `-d` or `--debug` to get cache logging and full stack traces if a command fails.

#### Org Info

```
./bin/project org info

url: https://api.github.com/orgs/opensearch-project
repos: 78
```

You can specify a GitHub org name for all commands, including `org info`.

```
./bin/project org info --org=aws
```

#### Org Members

Shows the difference between org members and member data.

```
./bin/project org members
```

#### Sorted List of Repos

```
./bin/project repos list
```

#### Org Teams

Shows org team memberships. Requires a `repo:admin` read-only PAT token.

```
./bin/project org teams
```

#### Code Owners

Audits repo CODEOWNERS files.

```
./bin/project codeowners audit
```

#### Maintainers

Shows maintainer stats.

```
./bin/project maintainers stats

As of 2023-05-17, 98 repos have 198 maintainers, including 17% (17/98) of repos with at least one of 15 external maintainers.
```

You can pass a date to find out stats for a given point in time.

```
./bin/project maintainers stats --date=2023-06-01

As of 2023-06-01, 103 repos have 202 maintainers, including 18% (19/103) of repos with at least one of 17 external maintainers.
```

Shows missing MAINTAINERS.md.

```
./bin/project maintainers missing
```

Audits maintainer lists for maintainers that have 0 commits on a project.

```
./bin/project maintainers audit
```

Review maintainer contents, permissions, and CODEOWNERS.

```
./bin/project maintainers permissions
```

Find maintainer e-mails from their commits.

```
./bin/project/maintainers emails
```

#### Contributor Stats

Shows most frequent contributors bucketed by members, contractors, students, and external.

```
./bin/project contributors stats

total = 5
members (2):
 https://github.com/dlvenable: 12
 https://github.com/zelinh: 10
contractors (3):
 https://github.com/...: 4
```

By default returns stats for the last full week. Specify `from` and `to` for different dates.

```
./bin/project contributors stats --from=2022-10-02 --to=2022-10-03
```

You can specify relative dates.

```
./bin/project contributors stats --from="last monday" --to="today"
```

For large organizations the default paging interval of 7 days may be too big and fail with `error: There are 1000+ PRs returned from a single query for 7 day(s), reduce --page.`. Decrease the page size.

```
./bin/project contributors stats --org=aws --page 3
```

#### Contributor Lists

Lists human contributors.

```
./bin/project contributors list

saratvemulapalli
sbcd90
...
```

Specify org and repo.

```
./bin/project contributors list --repo=aws-cli --org=aws
```

Specify multiple repos.

```
./bin/project contributors list --org=aws --repo=aws-cli --repo=deep-learning-containers
```

#### Pull Requests

Show a list of pull requests.

```
./bin/project prs list --org=aws --repo=aws-cli
```

#### Pull Request Stats

Shows bucketed contributions.

```
./bin/project prs stats

Between 2023-05-01 and 2023-05-07, 11% of contributions (34/284) were made by 21 external contributors (21/105).

students: 2.5% (7)
members: 81.0% (230)
external: 9.5% (27)
contractors: 6.7% (19)
unknown: 0.4% (1)

https://github.com/opensearch-project/project-website/pull/1024: add tracetest as a partner - [@mathnogueira]
https://github.com/opensearch-project/project-website/pull/1023: Add Hyland as partner - [@aborroy]
https://github.com/opensearch-project/opensearch-php/pull/85: Unset port for SigV4Handler, fixes #84 - [@shyim]
...
```

By default returns stats for the last full week. Specify `from` and `to` for different dates.

If the tool sees a new contributor, it will direct you to add aliases into [data/members.txt](data/members.txt), [data/contractors.txt](data/contractors.txt), [data/students.txt](data/students.txt), or [data/external.txt](data/external.txt) and open a browser page for each user so you can examine their account (specify `--ignore-unknown` to disable this behavior). Otherwise, it will output PRs and stats made by external contributors. The easiest way to lookup whether an account belongs to the org is with `./bin/project org members`. Commit and PR your changes to the data lists.

Get the stats since the beginning of year till today.

```
./bin/project prs stats --from=2022-01-01 --to=today
```

Get the stats for a given repo for last week.

```
./bin/project prs stats --org=aws --repo aws-cli
```

Get the stats for multiple repos.

```
./bin/project prs stats --org=aws --repo=aws-cli --repo=deep-learning-containers
```

Get the stats for an entire org and several repos.

```
./bin/project prs stats --org=opensearch-project --repo=aws/aws-cli --repo=aws/deep-learning-containers
```

Get the stats for unmerged (open and closed without being merged) PRs.

```
./bin/project prs stats --status=unmerged
```

#### Issues

Shows issues bucketed by label.

```
./bin/project issues labels

enhancement: 54
untriaged: 43
bug: 36
security vulnerability: 19
v2.4.0: 12
good first issue: 7
hacktoberfest: 6
autocut: 6
...
```

Specify org and repo.

```
./bin/project issues labels --org=aws --repo=aws-cli
```

By default returns stats for the last full week. Specify `from` and `to` for different dates.

Find untriaged issues.

```
./bin/project issues untriaged --from=2021-01-01 --to=2022-10-01
```

Find old issues labeled for a release.

```
./bin/project issues released --from=2021-01-01 --to=2022-10-01

v1.3.6: 3
v1.3.7: 1
v2.0.0: 3
v2.1.0: 6
v2.2.0: 31
v2.3.0: 11
v2.3.1: 1
v2.4.0: 193

OpenSearch
  v2.1.0: 1
  v2.2.0: 1
  v2.3.0: 2
  v2.4.0: 22
OpenSearch-Dashboards
  v1.3.0: 1
  v2.4.0: 38
```

#### Member Bios

Shows users in [data/users/members.txt](data/users/members.txt) that do not have some variation of org membership info in their GitHub bio.

```
./bin/project members check
```

#### DCO Signers

Shows name and email address from all contributors that have signed a developer certificate of origin on any commit.

```
./bin/project contributors dco-signers --from=2022-01-01 --to=2022-01-31 --org=opensearch-project --repo=OpenSearch
```

## Contributing

See [how to contribute to this project](CONTRIBUTING.md).

## Code of Conduct

This project has adopted the [Amazon Open Source Code of Conduct](CODE_OF_CONDUCT.md). For more information see the [Code of Conduct FAQ](https://aws.github.io/code-of-conduct-faq), or contact [opensource-codeofconduct@amazon.com](mailto:opensource-codeofconduct@amazon.com) with any additional questions or comments.

## Security

If you discover a potential security issue in this project we ask that you notify AWS/Amazon Security via our [vulnerability reporting page](http://aws.amazon.com/security/vulnerability-reporting/). Please do **not** create a public GitHub issue.

## License

This project is licensed under the [Apache v2.0 License](LICENSE.txt).

## Copyright

Copyright OpenSearch Contributors.
