# sc-hover-docs

VS Code extension: hover over any SuperCollider class name to see its summary,
description, method signatures with parameters, and a code example.

Covers all 734 classes that ship with SuperCollider 3.14.

## Install (pre-built)

```sh
code --install-extension sc-hover-docs-0.1.0.vsix
```

## Rebuild on a new machine (Mac or Pop!_OS)

```sh
cd sc-hover-docs
npm install
node scripts/buildDocs.mjs          # auto-detects SC install location
npm run compile
npm run package
code --install-extension sc-hover-docs-0.1.0.vsix
```

If SC is in a non-standard location pass the HelpSource path:
```sh
node scripts/buildDocs.mjs /path/to/SuperCollider/HelpSource
```

### Pop!_OS HelpSource locations

```
/usr/share/SuperCollider/HelpSource          # apt install
/usr/local/share/SuperCollider/HelpSource    # built from source
```

## Re-package after edits

```sh
npm run compile && npm run package
code --install-extension sc-hover-docs-0.1.0.vsix
```
