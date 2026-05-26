import * as vscode from 'vscode';
import * as cp from 'child_process';
import * as readline from 'readline';

export type ServerState = 'stopped' | 'starting' | 'running' | 'error';

export class SclangProcess {
    private proc: cp.ChildProcess | null = null;
    private rl:   readline.Interface  | null = null;
    private _state: ServerState = 'stopped';
    private output: vscode.OutputChannel;

    readonly onStateChange = new vscode.EventEmitter<ServerState>();

    constructor() {
        this.output = vscode.window.createOutputChannel('SuperCollider');
    }

    get state(): ServerState { return this._state; }

    private setState(s: ServerState) {
        this._state = s;
        this.onStateChange.fire(s);
    }

    start(sclangPath: string) {
        if (this.proc) return;
        this.output.show(true);
        this.output.appendLine(`[sc] starting sclang: ${sclangPath}`);
        this.setState('starting');

        try {
            this.proc = cp.spawn(sclangPath, [], {
                stdio: ['pipe', 'pipe', 'pipe'],
            });
        } catch (e) {
            this.output.appendLine(`[sc] failed to spawn: ${e}`);
            this.setState('error');
            return;
        }

        this.rl = readline.createInterface({ input: this.proc.stdout! });
        this.rl.on('line', line => {
            this.output.appendLine(line);
            // sclang prints "SuperCollider 3 server ready" when booted
            if (line.includes('server ready') || line.includes('localhost')) {
                this.setState('running');
            }
            // Starting up = still starting
            if (line.includes('compiling') || line.includes('Starting up')) {
                this.setState('starting');
            }
        });

        readline.createInterface({ input: this.proc.stderr! })
            .on('line', line => this.output.appendLine(`[err] ${line}`));

        this.proc.on('exit', (code) => {
            this.output.appendLine(`[sc] sclang exited (code ${code})`);
            this.proc = null;
            this.rl  = null;
            this.setState('stopped');
        });

        this.proc.on('error', (err) => {
            this.output.appendLine(`[sc] process error: ${err.message}`);
            this.setState('error');
        });
    }

    stop() {
        if (!this.proc) return;
        this.output.appendLine('[sc] stopping sclang…');
        // Send quit command first, then SIGTERM
        this.send('0.exit;');
        setTimeout(() => { this.proc?.kill('SIGTERM'); }, 500);
    }

    // Evaluate a string: write it to stdin with SC's eval terminator
    send(code: string) {
        if (!this.proc?.stdin) {
            vscode.window.showWarningMessage('sclang is not running. Start it first.');
            return;
        }
        const trimmed = code.trim();
        this.output.appendLine(`\n→ ${trimmed.slice(0, 120)}${trimmed.length > 120 ? '…' : ''}`);
        // sclang reads until \x0c (form feed) as the eval terminator
        this.proc.stdin.write(trimmed + '\x0c');
    }

    showOutput() {
        this.output.show(false);
    }

    dispose() {
        this.stop();
        this.output.dispose();
        this.onStateChange.dispose();
    }
}
