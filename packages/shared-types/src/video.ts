// TODO: Phase 1 — populate with full Video definitions
export interface VideoBase {
  id: string;
  title: string;
  uploaderId: string;
  status: 'pending' | 'processing' | 'published' | 'rejected';
  createdAt: string;
}
