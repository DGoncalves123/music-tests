import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';
import { SCDocs, SCClass } from './types';
import { scanDocument, renderVarInfo } from './variableScanner';

export class SCHoverProvider implements vscode.HoverProvider {
    private docs: SCDocs = {};
    private loaded = false;

    constructor(private context: vscode.ExtensionContext) {}

    private load() {
        if (this.loaded) return;
        const p = path.join(this.context.extensionPath, 'data', 'docs.json');
        try {
            this.docs = JSON.parse(fs.readFileSync(p, 'utf8'));
        } catch {
            this.docs = {};
        }
        this.loaded = true;
    }

    provideHover(document: vscode.TextDocument, position: vscode.Position): vscode.Hover | undefined {
        this.load();

        // Word range: allow ~ prefix for env vars, \ prefix for symbols
        const range = document.getWordRangeAtPosition(position, /[~\\]?[A-Za-z][A-Za-z0-9_]*/);
        if (!range) return;

        const word = document.getText(range);

        // 1. Try SC class docs (capitalized words, no ~ or \)
        if (/^[A-Z]/.test(word)) {
            const entry = this.docs[word];
            if (entry) return new vscode.Hover(this.renderClass(entry), range);
        }

        // 2. Try variable / symbol scan
        const varMap = scanDocument(document);

        // strip leading ~ or \ for lookup
        const bare = word.replace(/^[~\\]/, '');
        const info = varMap.get(word) ?? varMap.get(bare);
        if (info) {
            return new vscode.Hover(renderVarInfo(info, position.line), range);
        }

        return undefined;
    }

    private renderClass(c: SCClass): vscode.MarkdownString {
        const md = new vscode.MarkdownString();
        md.isTrusted = true;
        md.supportHtml = false;

        md.appendMarkdown(`$(symbol-class) **${c.name}** &nbsp; *${c.summary}*\n\n`);

        if (c.description) {
            const desc = c.description.length > 300
                ? c.description.slice(0, 297) + '…'
                : c.description;
            md.appendMarkdown(`${desc}\n\n`);
        }

        if (c.methods && c.methods.length > 0) {
            md.appendMarkdown(`---\n`);
            for (const m of c.methods.slice(0, 6)) {
                const argSig = m.args
                    .map(a => a.default ? `${a.name}: ${a.default}` : a.name)
                    .join(', ');
                md.appendMarkdown(`**\`.${m.name}(${argSig})\`**\n\n`);
                if (m.description) {
                    md.appendMarkdown(`${m.description}\n\n`);
                }
                for (const a of m.args) {
                    const defStr = a.default ? ` *(default: \`${a.default}\`)*` : '';
                    const descStr = a.description ? ` — ${a.description}` : '';
                    md.appendMarkdown(`- \`${a.name}\`${defStr}${descStr}\n`);
                }
                if (m.args.length > 0) md.appendMarkdown('\n');
            }
            if (c.methods.length > 6) {
                md.appendMarkdown(`*… and ${c.methods.length - 6} more methods.*\n\n`);
            }
        }

        if (c.example) {
            md.appendMarkdown(`---\n**Example**\n`);
            md.appendCodeblock(c.example.slice(0, 300), 'supercollider');
        }

        return md;
    }
}
