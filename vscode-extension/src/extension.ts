import * as vscode from 'vscode';
import { SCHoverProvider } from './hoverProvider';

export function activate(context: vscode.ExtensionContext) {
    const provider = new SCHoverProvider(context);
    context.subscriptions.push(
        vscode.languages.registerHoverProvider(
            { language: 'supercollider' },
            provider
        )
    );
}

export function deactivate() {}
