<!-- Renders at https://github.com/labelzoom — this is the public org landing page. -->

# LabelZoom

Barcode label conversion and design. Convert ZPL, EPL, TSPL, DPL and PDF between formats,
render labels to images, and design them in the browser — at
**[labelzoom.com](https://www.labelzoom.com)**.

The conversion API takes 13 source formats (`zpl` `epl` `tspl` `dpl` `xml` `json` `pdf`
`png` `bmp` `gif` `jpg` `jpeg` `url`) to 11 targets (the same list minus `jpg`, which
normalizes to `jpeg`, and `url`, which is a fetch instruction rather than a format).
**An API key is optional** — every client works anonymously against the free tier.

## Client SDKs

[**labelzoom-sdk**](https://github.com/labelzoom/labelzoom-sdk) is one repo publishing
eight packages that behave identically on the wire. They share a written contract
([`docs/API_CONTRACT.md`](https://github.com/labelzoom/labelzoom-sdk/blob/main/docs/API_CONTRACT.md))
and a language-neutral conformance suite of 83 fixtures that every SDK's tests execute, so
"works in Python" and "works in Rust" mean the same thing.

| Language | Package | Install |
|---|---|---|
| .NET | [`LabelZoom.Sdk`](https://www.nuget.org/packages/LabelZoom.Sdk) | `dotnet add package LabelZoom.Sdk` |
| Node | [`@labelzoom/sdk`](https://www.npmjs.com/package/@labelzoom/sdk) | `npm install @labelzoom/sdk` |
| Java | [`com.labelzoom:labelzoom-sdk`](https://central.sonatype.com/artifact/com.labelzoom/labelzoom-sdk) | Maven Central |
| Python | [`labelzoom-sdk`](https://pypi.org/project/labelzoom-sdk/) | `pip install labelzoom-sdk` |
| PHP | [`labelzoom/sdk`](https://packagist.org/packages/labelzoom/sdk) | `composer require labelzoom/sdk` |
| Go | [`labelzoom-sdk/go`](https://pkg.go.dev/github.com/labelzoom/labelzoom-sdk/go) | `go get github.com/labelzoom/labelzoom-sdk/go` |
| Ruby | [`labelzoom`](https://rubygems.org/gems/labelzoom) | `gem install labelzoom` |
| Rust | [`labelzoom`](https://crates.io/crates/labelzoom) | `cargo add labelzoom` |

[**labelzoom-sdk-php**](https://github.com/labelzoom/labelzoom-sdk-php) is a read-only
mirror of the PHP SDK, published because Packagist reads `composer.json` from a repository
root. File issues and PRs against
[labelzoom-sdk](https://github.com/labelzoom/labelzoom-sdk), not the mirror.

## Integrations

| | |
|---|---|
| [labelzoom-mcp](https://github.com/labelzoom/labelzoom-mcp) | An [MCP](https://modelcontextprotocol.io) server that lets an AI assistant convert a label and **render it to an image and look at it** — so it can check that ZPL produces the label you meant instead of reasoning about the source blind |
| [labelzoom-n8n-node](https://github.com/labelzoom/labelzoom-n8n-node) | [n8n](https://n8n.io) community node — convert labels between formats inside a workflow |

Both are on `0.1.0` and not yet published to npm; build them from source for now.

## Scripts and utilities

| | |
|---|---|
| [python-zpl-utils](https://github.com/labelzoom/python-zpl-utils) | Standalone Python scripts: PDF→ZPL, PNG→ZPL, and send-ZPL-to-a-printer |
| [groovy-zpl-utils](https://github.com/labelzoom/groovy-zpl-utils) | The same idea in Groovy: PNG→ZPL and send-ZPL-to-a-printer. No dependencies |

Both are copy-and-run scripts rather than published packages — useful when you want one
conversion and not a dependency.

## MOCA clients

Clients for MOCA, the query language and server protocol used by Blue Yonder (formerly JDA
/ RedPrairie) warehouse management systems. Sponsored by LabelZoom, BSD-3-Clause, and
independent of the label platform.

| | |
|---|---|
| [labelzoom-moca-client-java](https://github.com/labelzoom/labelzoom-moca-client-java) | `com.labelzoom:labelzoom-moca-client-java` — published to GitHub Packages |
| [labelzoom-moca-client-dotnet](https://github.com/labelzoom/labelzoom-moca-client-dotnet) | [`LabelZoom.MocaClient`](https://www.nuget.org/packages/LabelZoom.MocaClient) on NuGet (`netstandard2.0`) |

## Org configuration

[**.github**](https://github.com/labelzoom/.github) holds the reusable GitHub Actions
workflows every LabelZoom repo's CI calls, the workflow templates, and the community
health files that inherit org-wide — including this page. Consumers pin `@v1`, a moving
tag advanced only by an explicit release step.

## Docs and API

- **Documentation:** [docs.labelzoom.com](https://docs.labelzoom.com)
- **API:** [labelzoom.com/api](https://www.labelzoom.com/api)
- **Try it in the browser:** [web app](https://www.labelzoom.com/app/) ·
  [label designer](https://www.labelzoom.com/designer)

## Security

Found a vulnerability? Please report it privately — see
[SECURITY.md](https://github.com/labelzoom/.github/blob/main/SECURITY.md). Not through a
public issue.
