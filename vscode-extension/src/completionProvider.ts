import * as vscode from 'vscode';
import * as path from 'path';
import * as fs from 'fs';
import { SCDocs } from './types';

export class SCCompletionProvider implements vscode.CompletionItemProvider {
    private docs: SCDocs = {};
    private loaded = false;

    constructor(private extensionPath: string) {}

    private load() {
        if (this.loaded) return;
        try {
            const p = path.join(this.extensionPath, 'data', 'docs.json');
            this.docs = JSON.parse(fs.readFileSync(p, 'utf8'));
        } catch { /* silent */ }
        this.loaded = true;
    }

    provideCompletionItems(
        document: vscode.TextDocument,
        position: vscode.Position,
    ): vscode.CompletionItem[] {
        this.load();

        const linePrefix = document.lineAt(position).text.slice(0, position.character);

        // Trigger for capitalized class names
        const classMatch = linePrefix.match(/([A-Z][A-Za-z0-9_]*)$/);
        // Trigger for method calls: something.partialMethod
        const methodMatch = linePrefix.match(/\.([a-z][A-Za-z0-9_]*)$/);

        if (classMatch) {
            const prefix = classMatch[1];
            return Object.keys(this.docs)
                .filter(name => name.startsWith(prefix) && name !== prefix)
                .slice(0, 60)
                .map(name => {
                    const entry = this.docs[name];
                    const item = new vscode.CompletionItem(name, vscode.CompletionItemKind.Class);
                    item.detail = entry.summary;
                    item.documentation = new vscode.MarkdownString(
                        entry.description?.slice(0, 200) ?? ''
                    );
                    // Insert snippet: ClassName() with cursor inside
                    item.insertText = new vscode.SnippetString(`${name}($0)`);
                    return item;
                });
        }

        if (methodMatch) {
            const prefix = methodMatch[1];
            // Collect all methods from all classes matching the prefix
            const seen = new Set<string>();
            const items: vscode.CompletionItem[] = [];
            for (const cls of Object.values(this.docs)) {
                for (const m of cls.methods ?? []) {
                    if (m.name.startsWith(prefix) && !seen.has(m.name)) {
                        seen.add(m.name);
                        const item = new vscode.CompletionItem(
                            m.name,
                            vscode.CompletionItemKind.Method
                        );
                        item.detail = m.description?.slice(0, 80);
                        if (m.args.length > 0) {
                            // Snippet with tab stops for each argument
                            const argSnippet = m.args
                                .map((a, i) => `${a.name}: \${${i + 1}:${a.default ?? a.name}}`)
                                .join(', ');
                            item.insertText = new vscode.SnippetString(`${m.name}(${argSnippet})$0`);
                        }
                        items.push(item);
                        if (items.length >= 60) break;
                    }
                }
                if (items.length >= 60) break;
            }
            return items;
        }

        return [];
    }
}
