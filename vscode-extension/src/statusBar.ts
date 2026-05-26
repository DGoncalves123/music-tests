import * as vscode from 'vscode';
import { SclangProcess, ServerState } from './sclangProcess';

const ICONS: Record<ServerState, string> = {
    stopped:  '$(debug-stop)',
    starting: '$(loading~spin)',
    running:  '$(radio-tower)',
    error:    '$(error)',
};

const TOOLTIPS: Record<ServerState, string> = {
    stopped:  'SuperCollider — stopped. Click to start.',
    starting: 'SuperCollider — starting…',
    running:  'SuperCollider — running. Click to stop.',
    error:    'SuperCollider — error. Click to restart.',
};

export class SCStatusBar {
    private item: vscode.StatusBarItem;

    constructor(private proc: SclangProcess) {
        this.item = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Right, 100
        );
        this.item.command = 'sc.toggleServer';
        this.update(proc.state);
        proc.onStateChange.event(s => this.update(s));
        this.item.show();
    }

    private update(state: ServerState) {
        this.item.text    = `${ICONS[state]} SC`;
        this.item.tooltip = TOOLTIPS[state];
        this.item.color   = state === 'running'  ? new vscode.ThemeColor('terminal.ansiGreen')
                          : state === 'error'    ? new vscode.ThemeColor('terminal.ansiRed')
                          : state === 'starting' ? new vscode.ThemeColor('terminal.ansiYellow')
                          : undefined;
    }

    dispose() { this.item.dispose(); }
}
