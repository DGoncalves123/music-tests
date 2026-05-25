#!/usr/bin/env node
// buildDocs.mjs — parses SuperCollider .schelp files → data/docs.json
//
// Usage:
//   node scripts/buildDocs.mjs [helpSourcePath]
//
// helpSourcePath defaults to the macOS location. On Pop!_OS it's usually:
//   /usr/share/SuperCollider/HelpSource
//   or wherever you installed SC.
//
// Run from the sc-hover-docs/ directory.

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const DEFAULT_PATHS = [
    // macOS user install
    `${process.env.HOME}/Applications/SuperCollider.app/Contents/Resources/HelpSource`,
    // macOS system install
    '/Applications/SuperCollider.app/Contents/Resources/HelpSource',
    // Linux
    '/usr/share/SuperCollider/HelpSource',
    '/usr/local/share/SuperCollider/HelpSource',
];

const helpSourcePath = process.argv[2]
    || DEFAULT_PATHS.find(p => fs.existsSync(p))
    || null;

if (!helpSourcePath) {
    console.error('Could not find HelpSource. Pass the path as an argument:');
    console.error('  node scripts/buildDocs.mjs /path/to/HelpSource');
    process.exit(1);
}

const classesDir = path.join(helpSourcePath, 'Classes');
if (!fs.existsSync(classesDir)) {
    console.error(`Classes dir not found at: ${classesDir}`);
    process.exit(1);
}

const files = fs.readdirSync(classesDir).filter(f => f.endsWith('.schelp'));
console.log(`Parsing ${files.length} .schelp files from ${classesDir}…`);

function stripMarkup(s) {
    return s
        .replace(/link::[^:]+::/g, '')         // link::Classes/Foo::
        .replace(/code::\s*([\s\S]*?)\s*::/g, '`$1`')  // code::...::
        .replace(/strong::(.*?)::/g, '**$1**')  // strong::...::
        .replace(/emphasis::(.*?)::/g, '*$1*')  // emphasis::...::
        .replace(/teletype::(.*?)::/g, '`$1`')  // teletype::...::
        .replace(/::\s*$/gm, '')
        .replace(/\n{3,}/g, '\n\n')
        .trim();
}

function parseSchelp(src) {
    const result = { name: '', summary: '', description: '', methods: [], example: '' };

    // class name
    const classMatch = src.match(/^class::\s*(.+)$/m);
    if (classMatch) result.name = classMatch[1].trim();

    // summary
    const summaryMatch = src.match(/^summary::\s*(.+)$/m);
    if (summaryMatch) result.summary = summaryMatch[1].trim();

    // description block
    const descMatch = src.match(/Description::\s*([\s\S]*?)(?=\n(?:classmethods|instancemethods|Examples?|argument|method)::|$)/i);
    if (descMatch) {
        result.description = stripMarkup(descMatch[1]).slice(0, 600);
    }

    // first code example
    const codeMatch = src.match(/code::\s*([\s\S]*?)\s*::/);
    if (codeMatch) {
        result.example = codeMatch[1].trim().slice(0, 400);
    }

    // methods: find "method::" blocks
    const methodRegex = /^method::\s*(.+)$([\s\S]*?)(?=^method::|^classmethods::|^instancemethods::|^Examples?::|^section::|$)/gm;
    let m;
    while ((m = methodRegex.exec(src)) !== null) {
        const methodNames = m[1].split(',').map(s => s.trim());
        const body = m[2];

        // description = text before first argument::
        const descEnd = body.search(/^argument::/m);
        const methodDesc = stripMarkup(
            (descEnd > -1 ? body.slice(0, descEnd) : body).trim()
        ).slice(0, 200);

        // arguments
        const args = [];
        const argRegex = /^argument::\s*(\S+)([\s\S]*?)(?=^argument::|^method::|^discussion::|^returns::|$)/gm;
        let a;
        while ((a = argRegex.exec(body)) !== null) {
            const argName = a[1].trim();
            const argDesc = stripMarkup(a[2]).slice(0, 120);
            // pick up defaults like "= 0" or "= Done.none" from the body
            const defMatch = body.match(new RegExp(`argument::\\s*${argName}[\\s\\S]*?\\(default:\\s*([^)]+)\\)`, 'i'));
            args.push({ name: argName, description: argDesc, default: defMatch ? defMatch[1].trim() : undefined });
        }

        for (const name of methodNames) {
            result.methods.push({ name, description: methodDesc, args });
        }
    }

    return result;
}

const docs = {};
let count = 0;
for (const file of files) {
    const src = fs.readFileSync(path.join(classesDir, file), 'utf8');
    const parsed = parseSchelp(src);
    if (parsed.name) {
        docs[parsed.name] = parsed;
        count++;
    }
}

const outPath = path.join(__dirname, '..', 'data', 'docs.json');
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, JSON.stringify(docs, null, 2));
console.log(`✓ Wrote ${count} classes to ${outPath}`);
