export interface SCArgument {
    name: string;
    description: string;
    default?: string;
}

export interface SCMethod {
    name: string;
    description: string;
    args: SCArgument[];
}

export interface SCClass {
    name: string;
    summary: string;
    description: string;
    methods: SCMethod[];
    example?: string;
}

export type SCDocs = Record<string, SCClass>;
