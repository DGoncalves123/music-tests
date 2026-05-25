import * as vscode from 'vscode';

export interface Assignment {
    value: string;
    line: number;
}

export interface VarInfo {
    kind: 'envvar' | 'localvar' | 'synthdef' | 'pdef' | 'syntharg' | 'named';
    label: string;
    firstLine: number;
    assignments: Assignment[];   // all assignments, chronological
    detail?: string;
    synthName?: string;          // for syntharg: which SynthDef it belongs to
    argDefault?: string;         // for syntharg: the declared default
}

export type VarMap = Map<string, VarInfo>;

export function scanDocument(doc: vscode.TextDocument): VarMap {
    const map: VarMap = new Map();
    const lines = doc.getText().split('\n');
    let currentSynthDef: string | null = null;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i].replace(/\/\/.*$/, '').trim();

        // ── SynthDef ─────────────────────────────────────────────────────
        const synthDefMatch = line.match(/SynthDef\s*\(\s*\\([A-Za-z0-9_]+)/);
        if (synthDefMatch) {
            currentSynthDef = synthDefMatch[1];
            upsert(map, synthDefMatch[1], {
                kind: 'synthdef',
                label: '\\' + synthDefMatch[1],
                firstLine: i,
                assignments: [],
                detail: 'SynthDef',
            });
            // Scan |args| over next few lines
            const argSrc = lines.slice(i, i + 5).join(' ').replace(/\/\/[^\n]*/g, '');
            const argBlock = argSrc.match(/\|([^|]+)\|/);
            if (argBlock) {
                for (const part of argBlock[1].split(',')) {
                    const m = part.trim().match(/^([A-Za-z_][A-Za-z0-9_]*)\s*(?:=\s*([^\s,]+))?/);
                    if (m && m[1] !== 'out') {
                        upsert(map, m[1], {
                            kind: 'syntharg',
                            label: m[1],
                            firstLine: i,
                            assignments: m[2] ? [{ value: m[2], line: i }] : [],
                            detail: `Argument of SynthDef \\${currentSynthDef}`,
                            synthName: currentSynthDef ?? undefined,
                            argDefault: m[2],
                        });
                    }
                }
            }
        }
        if (line.includes('.add') || line.match(/^\}\s*\)\s*;?\s*$/)) {
            currentSynthDef = null;
        }

        // ── Pdef / Ndef / Tdef ───────────────────────────────────────────
        const pdefMatch = line.match(/(Pdef|Ndef|Tdef)\s*\(\s*\\([A-Za-z0-9_]+)/);
        if (pdefMatch) {
            upsert(map, pdefMatch[2], {
                kind: 'pdef',
                label: '\\' + pdefMatch[2],
                firstLine: i,
                assignments: [],
                detail: `${pdefMatch[1]} — pattern/node definition`,
            });
        }

        // ── Environment variable ~name = value ───────────────────────────
        const envAssign = line.match(/^(~[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+?)\s*;?\s*$/);
        if (envAssign) {
            const name = envAssign[1];
            const val  = collapse(envAssign[2]).slice(0, 100);
            const existing = map.get(name);
            if (existing) {
                existing.assignments.push({ value: val, line: i });
            } else {
                map.set(name, {
                    kind: 'envvar',
                    label: name,
                    firstLine: i,
                    assignments: [{ value: val, line: i }],
                    detail: 'Environment variable',
                });
            }
        }

        // ── Local var declaration ─────────────────────────────────────────
        const varDecl = line.match(/^var\s+(.+?)\s*;?\s*$/);
        if (varDecl) {
            for (const part of varDecl[1].split(',')) {
                const m = part.trim().match(/^([A-Za-z_][A-Za-z0-9_]*)\s*(?:=\s*(.+))?$/);
                if (m && !map.has(m[1])) {
                    map.set(m[1], {
                        kind: 'localvar',
                        label: m[1],
                        firstLine: i,
                        assignments: m[2] ? [{ value: collapse(m[2]).slice(0, 100), line: i }] : [],
                        detail: 'Local variable',
                    });
                }
            }
        }

        // ── Local var reassignment (no var keyword) ───────────────────────
        const localReassign = line.match(/^([a-z][A-Za-z0-9_]*)\s*=\s*(.+?)\s*;?\s*$/);
        if (localReassign) {
            const name = localReassign[1];
            const val  = collapse(localReassign[2]).slice(0, 100);
            const existing = map.get(name);
            if (existing && existing.kind === 'localvar') {
                existing.assignments.push({ value: val, line: i });
            }
        }
    }

    return map;
}

function collapse(s: string): string {
    return s.replace(/\s+/g, ' ').trim();
}

function upsert(map: VarMap, key: string, info: VarInfo) {
    if (!map.has(key)) map.set(key, info);
}

export function renderVarInfo(info: VarInfo, hoverLine: number): vscode.MarkdownString {
    const md = new vscode.MarkdownString();
    md.isTrusted = true;

    const icons: Record<VarInfo['kind'], string> = {
        envvar:   '$(globe)',
        localvar: '$(symbol-variable)',
        synthdef: '$(symbol-class)',
        pdef:     '$(symbol-event)',
        syntharg: '$(symbol-parameter)',
        named:    '$(symbol-module)',
    };

    md.appendMarkdown(`${icons[info.kind]} **${info.label}** &nbsp;—&nbsp; *${info.detail}*\n\n`);

    // SynthDef arg: show declared default prominently
    if (info.kind === 'syntharg') {
        if (info.argDefault !== undefined) {
            md.appendMarkdown(`**Default:** \`${info.argDefault}\`\n\n`);
        } else {
            md.appendMarkdown(`*No default declared*\n\n`);
        }
    }

    // Latest assigned value (most useful thing)
    if (info.assignments.length > 0) {
        const last = info.assignments[info.assignments.length - 1];
        const note = last.line === hoverLine
            ? ' *(this line)*'
            : ` *(line ${last.line + 1})*`;
        md.appendMarkdown(`**Last set to:** \`${last.value}\`${note}\n\n`);
    } else if (info.kind !== 'syntharg') {
        md.appendMarkdown(`*Never assigned a value*\n\n`);
    }

    // Full assignment history if more than one
    if (info.assignments.length > 1) {
        md.appendMarkdown(`---\n**All assignments** (${info.assignments.length})\n\n`);
        const shown = [...info.assignments].reverse().slice(0, 6);
        for (const a of shown) {
            const marker = a === info.assignments[info.assignments.length - 1] ? ' ← current' : '';
            md.appendMarkdown(`- **line ${a.line + 1}:** \`${a.value}\`${marker}\n`);
        }
        if (info.assignments.length > 6) {
            md.appendMarkdown(`\n*… and ${info.assignments.length - 6} earlier.*\n`);
        }
        md.appendMarkdown('\n');
    }

    // Defined on line (only when not already shown via assignments)
    if (info.assignments.length === 0) {
        md.appendMarkdown(`*Defined on line ${info.firstLine + 1}*\n`);
    }

    return md;
}
