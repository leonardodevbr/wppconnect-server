import { Request } from 'express';
import { clientsArray } from './sessionUtil';

export class SessionRecoveryManager {
  private retryInterval: number = 30000; // 30 segundos
  private maxRetries: number = 10;
  private retryCount: Map<string, number> = new Map();

  constructor() {
    this.startRecoveryMonitoring();
  }

  private startRecoveryMonitoring() {
    setInterval(() => {
      this.checkAndRecoverSessions();
    }, this.retryInterval);
  }

  private async checkAndRecoverSessions() {
    for (const [sessionName, client] of Object.entries(clientsArray as any)) {
      try {
        const isConnected = await client.isConnected();
        
        if (!isConnected) {
          console.log(`🔄 Sessão ${sessionName} desconectada. Tentando reconectar...`);
          await this.recoverSession(sessionName, client);
        } else {
          // Reset retry count se conectado
          this.retryCount.set(sessionName, 0);
        }
      } catch (error) {
        console.error(`❌ Erro ao verificar sessão ${sessionName}:`, error);
        await this.recoverSession(sessionName, client);
      }
    }
  }

  private async recoverSession(sessionName: string, client: any) {
    const currentRetries = this.retryCount.get(sessionName) || 0;
    
    if (currentRetries >= this.maxRetries) {
      console.log(`⚠️ Sessão ${sessionName} excedeu máximo de tentativas (${this.maxRetries})`);
      return;
    }

    try {
      console.log(`🔄 Tentativa ${currentRetries + 1}/${this.maxRetries} de reconexão para ${sessionName}`);
      
      // Tentar reconectar
      await client.connect();
      
      // Verificar se conectou
      const isConnected = await client.isConnected();
      if (isConnected) {
        console.log(`✅ Sessão ${sessionName} reconectada com sucesso!`);
        this.retryCount.set(sessionName, 0);
      } else {
        throw new Error('Falha na reconexão');
      }
    } catch (error) {
      console.error(`❌ Falha na tentativa ${currentRetries + 1} para ${sessionName}:`, error);
      this.retryCount.set(sessionName, currentRetries + 1);
    }
  }

  public resetRetryCount(sessionName: string) {
    this.retryCount.set(sessionName, 0);
  }

  public getRetryCount(sessionName: string): number {
    return this.retryCount.get(sessionName) || 0;
  }
}

// Instância global do gerenciador de recuperação
export const sessionRecoveryManager = new SessionRecoveryManager();
