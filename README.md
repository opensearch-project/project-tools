- [OpenSearch Project Tools](#opensearch-project-tools)
  - [Usage](#usage)
    - [Global Options](#global-options)
      - [Tokens](#tokens)
      - [Quiet](#quiet)
      - [Caching](#caching)
      - [Debug Logging](#debug-logging)
    - [Org Info](#org-info)
    - [Org Members](#org-members)
    - [Sorted List of Repos](#sorted-list-of-repos)
    - [Contributor Stats](#contributor-stats)
    - [Contributor Lists](#contributor-lists)
    - [Pull Requests](#pull-requests)
    - [Pull Request Stats](#pull-request-stats)
    - [Issues](#issues)
    - [Member Bios](#member-bios)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [Security](#security)
- [License](#license)
- [Copyright](#copyright)

## OpenSearch Project Tools

Tools to gather stats on a GitHub organization.

### Usage

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
./bin/project --org aws org info
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

#### Contributor Stats

Shows most frequent contributors bucketed by members, contractors, and external.

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
./bin/project --org aws contributors stats --page 3
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
./bin/project --org aws contributors list --repo aws-cli
```

Specify multiple repos.

```
./bin/project --org aws contributors list --repo aws-cli --repo deep-learning-containers
```

#### Pull Requests

Show a list of pull requests.

```
./bin/project --org aws prs list --repo aws-cli
```

#### Pull Request Stats

Shows bucketed contributions.

```
./bin/project prs stats

Between 2022-10-03 and 2022-10-09, 5% of contributions (18/346) were made by 9 external contributors (9/102).

https://github.com/opensearch-project/project-website/pull/1024: add tracetest as a partner - [@mathnogueira]
https://github.com/opensearch-project/project-website/pull/1023: Add Hyland as partner - [@aborroy]
https://github.com/opensearch-project/opensearch-php/pull/85: Unset port for SigV4Handler, fixes #84 - [@shyim]
...
```

By default returns stats for the last full week. Specify `from` and `to` for different dates.

If the tool sees a new contributor, it will direct you to add aliases into [data/members.txt](data/members.txt), [data/contractors.txt](data/contractors.txt), or [data/external.txt](data/external.txt) and open a browser page for each user so you can examine their account (specify `--ignore-unknown` to disable this behavior). Otherwise, it will output PRs and stats made by external contributors. The easiest way to lookup whether an account belongs to the org is with `./bin/project org members`. Commit and PR your changes to the data lists.

Get the stats since the beginning of year till today.

```
./bin/project prs stats --from=2022-01-01 --to=today
```

Get the stats for a given repo for last week.

```
./bin/project --org aws prs stats --repo aws-cli
```

Get the stats for multiple repos.

```
./bin/project --org aws prs stats --repo aws-cli --repo deep-learning-containers
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
./bin/project --org aws issues labels --repo aws-cli
```

By default returns stats for the last full week. Specify `from` and `to` for different dates.

Find untriaged issues.

```
./bin/project issues untriaged --from=2021-01-01 --to=2022-10-01
```

Find old issues labeled for a release.

```
./bin/project issues released --from=2021-01-01 --to=2022-10-01
```

#### Member Bios

Shows users in [data/users/members.txt](data/users/members.txt) that do not have some variation of org membership info in their GitHub bio.

```
./bin/project members check
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
