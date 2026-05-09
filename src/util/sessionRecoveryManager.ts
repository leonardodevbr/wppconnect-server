class SessionRecoveryManager {
  private interval: NodeJS.Timeout | null = null;

  start() {
    // Desabilitado — client.isConnected e client.connect não existem na API do WPPConnect
    // O WPPConnect gerencia reconexão internamente via eventos
  }

  stop() {
    if (this.interval) {
      clearTimeout(this.interval);
      this.interval = null;
    }
  }

  async checkAndRecoverSessions() {
    // Desabilitado intencionalmente
    return;
  }

  /** Compatível com GET /api/:session/recovery-status (recovery desabilitado → sempre 0) */
  getRetryCount(_sessionName: string): number {
    return 0;
  }
}

export const sessionRecoveryManager = new SessionRecoveryManager();
