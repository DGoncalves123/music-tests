import * as vscode from 'vscode';
import { SCHoverProvider } from './hoverProvider';
import { SCCompletionProvider } from './completionProvider';
import { SclangProcess } from './sclangProcess';
import { SCStatusBar } from './statusBar';
import { getEvalText } from './blockEval';

const SC_LANG = { language: 'supercollider' };

function getSclangPath(): string {
    const cfg = vscode.workspace.getConfiguration('supercollider');
    return (
        cfg.get<string>('sclang.cmd') ||
        cfg.get<string>('sclangPath') ||
        'sclang'
    );
}

export function activate(context: vscode.ExtensionContext) {
    const proc      = new SclangProcess();
    const statusBar = new SCStatusBar(proc);

    // ── Hover ─────────────────────────────────────────────────────────
    context.subscriptions.push(
        vscode.languages.registerHoverProvider(SC_LANG, new SCHoverProvider(context))
    );

    // ── Completion ────────────────────────────────────────────────────
    context.subscriptions.push(
        vscode.languages.registerCompletionItemProvider(
            SC_LANG,
            new SCCompletionProvider(context.extensionPath),
            '.',
        )
    );

    // ── Toggle server (status bar click) ──────────────────────────────
    context.subscriptions.push(
        vscode.commands.registerCommand('sc.toggleServer', () => {
            if (proc.state === 'stopped' || proc.state === 'error') {
                proc.start(getSclangPath());
            } else {
                proc.stop();
            }
        })
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('sc.startServer', () => proc.start(getSclangPath()))
    );

    context.subscriptions.push(
        vscode.commands.registerCommand('sc.stopServer', () => proc.stop())
    );

    // ── Flash helper ──────────────────────────────────────────────────
    // Brightens the range then fades it out over ~500ms in two steps.
    function flash(editor: vscode.TextEditor, range: vscode.Range) {
        const bright = vscode.window.createTextEditorDecorationType({
            backgroundColor: 'rgba(130, 200, 255, 0.45)',
            borderRadius: '3px',
        });
        const dim = vscode.window.createTextEditorDecorationType({
            backgroundColor: 'rgba(130, 200, 255, 0.15)',
            borderRadius: '3px',
        });
        editor.setDecorations(bright, [range]);
        setTimeout(() => {
            bright.dispose();
            editor.setDecorations(dim, [range]);
            setTimeout(() => dim.dispose(), 250);
        }, 200);
    }

    // ── Evaluate block/line at cursor — Cmd+Enter ─────────────────────
    //
    // When the entire file is selected (Cmd+A then Cmd+Enter) AND the file
    // is saved on disk, we send  "path".load;  so that sclang sets
    // thisProcess.nowExecutingPath correctly (required for startup.scd).
    // For partial selections or unsaved buffers we send the raw text.
    context.subscriptions.push(
        vscode.commands.registerCommand('sc.evalBlock', () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) return;

            const doc   = editor.document;
            const { text, range } = getEvalText(editor);
            if (!text.trim()) return;

            const isWholeFile = !editor.selection.isEmpty &&
                doc.offsetAt(editor.selection.start) === 0 &&
                doc.offsetAt(editor.selection.end) === doc.getText().length;

            const filePath = doc.uri.scheme === 'file' ? doc.uri.fsPath : null;

            if (isWholeFile && filePath) {
                proc.send(`"${filePath.replace(/\\/g, '\\\\')}".load;`);
            } else {
                proc.send(text);
            }

            flash(editor, range);
        })
    );

    // ── Load current file — Cmd+Shift+Enter ───────────────────────────
    context.subscriptions.push(
        vscode.commands.registerCommand('sc.loadFile', () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) return;
            const filePath = editor.document.uri.fsPath;
            if (!filePath) { vscode.window.showWarningMessage('Save the file first.'); return; }
            // Flash the whole document
            const all = new vscode.Range(
                editor.document.positionAt(0),
                editor.document.positionAt(editor.document.getText().length)
            );
            flash(editor, all);
            proc.send(`"${filePath.replace(/\\/g, '\\\\')}".load;`);
        })
    );

    // ── Stop all sound — Cmd+. ────────────────────────────────────────
    context.subscriptions.push(
        vscode.commands.registerCommand('sc.stopSound', () => proc.send('CmdPeriod.run;'))
    );

    // ── Show SC output panel ──────────────────────────────────────────
    context.subscriptions.push(
        vscode.commands.registerCommand('sc.showOutput', () => proc.showOutput())
    );

    context.subscriptions.push(proc, statusBar);
}

export function deactivate() {}
