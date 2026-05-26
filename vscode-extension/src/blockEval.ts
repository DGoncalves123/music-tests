import * as vscode from 'vscode';

// Find the enclosing ( ... ) block around the cursor.
// If no enclosing parens, return just the current line.
export function getEvalText(editor: vscode.TextEditor): { text: string; range: vscode.Range } {
    const doc = editor.document;
    const pos = editor.selection.active;

    // If there's a non-empty selection, eval that
    if (!editor.selection.isEmpty) {
        return {
            text: doc.getText(editor.selection),
            range: editor.selection,
        };
    }

    const text = doc.getText();
    const offset = doc.offsetAt(pos);

    // Walk backwards to find matching (
    let depth = 0;
    let start = -1;
    for (let i = offset; i >= 0; i--) {
        if (text[i] === ')') depth++;
        else if (text[i] === '(') {
            if (depth === 0) { start = i; break; }
            depth--;
        }
    }

    // Walk forwards to find matching )
    let end = -1;
    if (start !== -1) {
        depth = 0;
        for (let i = start; i < text.length; i++) {
            if (text[i] === '(') depth++;
            else if (text[i] === ')') {
                depth--;
                if (depth === 0) { end = i; break; }
            }
        }
    }

    if (start !== -1 && end !== -1) {
        const range = new vscode.Range(doc.positionAt(start), doc.positionAt(end + 1));
        return { text: doc.getText(range), range };
    }

    // Fallback: current line
    const line = doc.lineAt(pos.line);
    return { text: line.text.trim(), range: line.range };
}
