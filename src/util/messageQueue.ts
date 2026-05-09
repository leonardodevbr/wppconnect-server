/*
 * Copyright 2025 WPPConnect Team
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Request, Response } from 'express';
import { randomBytes } from 'crypto';

interface QueueMessage {
  id: string;
  session: string;
  type: string;
  data: any;
  status: 'pending' | 'processing' | 'sent' | 'failed';
  createdAt: Date;
  processedAt?: Date;
  attempts: number;
  maxAttempts: number;
  error?: string;
}

interface QueueConfig {
  maxConcurrent: number;
  retryDelay: number;
  maxRetries: number;
}

class MessageQueue {
  private queues: Map<string, QueueMessage[]> = new Map();
  private processing: Map<string, Set<string>> = new Map();
  private config: QueueConfig;

  constructor(config: QueueConfig = {
    maxConcurrent: 5,
    retryDelay: 5000,
    maxRetries: 3
  }) {
    this.config = config;
    this.startProcessor();
  }

  // Adicionar mensagem à fila
  addToQueue(session: string, type: string, data: any): string {
    const messageId = randomBytes(16).toString('hex');
    const message: QueueMessage = {
      id: messageId,
      session,
      type,
      data,
      status: 'pending',
      createdAt: new Date(),
      attempts: 0,
      maxAttempts: this.config.maxRetries
    };

    if (!this.queues.has(session)) {
      this.queues.set(session, []);
    }

    this.queues.get(session)!.push(message);
    return messageId;
  }

  // Processar fila de uma sessão
  private async processQueue(session: string) {
    const queue = this.queues.get(session);
    if (!queue || queue.length === 0) return;

    const processing = this.processing.get(session) || new Set();
    if (processing.size >= this.config.maxConcurrent) return;

    const message = queue.find(m => m.status === 'pending');
    if (!message) return;

    processing.add(message.id);
    this.processing.set(session, processing);

    try {
      message.status = 'processing';
      message.attempts++;

      // Aqui você implementaria a lógica específica de envio
      await this.processMessage(message);

      message.status = 'sent';
      message.processedAt = new Date();
    } catch (error) {
      message.status = 'failed';
      message.error = error instanceof Error ? error.message : 'Unknown error';

      if (message.attempts < message.maxAttempts) {
        // Reagendar para nova tentativa
        setTimeout(() => {
          message.status = 'pending';
          this.processQueue(session);
        }, this.config.retryDelay);
      }
    } finally {
      processing.delete(message.id);
      this.processing.set(session, processing);
    }
  }

  // Processar mensagem específica
  private async processMessage(message: QueueMessage): Promise<void> {
    // Implementar lógica específica baseada no tipo
    switch (message.type) {
      case 'text':
        // await this.sendTextMessage(message);
        break;
      case 'image':
        // await this.sendImageMessage(message);
        break;
      case 'document':
        // await this.sendDocumentMessage(message);
        break;
      default:
        throw new Error(`Unknown message type: ${message.type}`);
    }
  }

  // Iniciar processador de filas
  private startProcessor() {
    setInterval(() => {
      for (const session of this.queues.keys()) {
        this.processQueue(session);
      }
    }, 1000); // Processar a cada segundo
  }

  // Obter status da fila
  getQueueStatus(session: string) {
    const queue = this.queues.get(session) || [];
    const processing = this.processing.get(session) || new Set();

    return {
      total: queue.length,
      pending: queue.filter(m => m.status === 'pending').length,
      processing: processing.size,
      sent: queue.filter(m => m.status === 'sent').length,
      failed: queue.filter(m => m.status === 'failed').length,
      messages: queue.slice(-10) // Últimas 10 mensagens
    };
  }

  // Limpar fila
  clearQueue(session: string) {
    this.queues.set(session, []);
    this.processing.set(session, new Set());
  }

  // Remover mensagem específica
  removeMessage(session: string, messageId: string) {
    const queue = this.queues.get(session);
    if (queue) {
      const index = queue.findIndex(m => m.id === messageId);
      if (index > -1) {
        queue.splice(index, 1);
      }
    }
  }

  // Obter todas as filas
  getAllQueues() {
    const result: any = {};
    for (const [session, queue] of this.queues.entries()) {
      result[session] = this.getQueueStatus(session);
    }
    return result;
  }
}

// Instância global da fila
export const messageQueue = new MessageQueue();

// Controllers para as rotas
export async function getQueueStatus(req: Request, res: Response): Promise<any> {
  const { session } = req.params;
  
  try {
    const status = messageQueue.getQueueStatus(session);
    res.status(200).json({
      status: 'success',
      data: status
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Error getting queue status',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

export async function clearQueue(req: Request, res: Response): Promise<any> {
  const { session } = req.params;
  
  try {
    messageQueue.clearQueue(session);
    res.status(200).json({
      status: 'success',
      message: 'Queue cleared successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Error clearing queue',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

export async function removeMessage(req: Request, res: Response): Promise<any> {
  const { session, messageId } = req.params;
  
  try {
    messageQueue.removeMessage(session, messageId);
    res.status(200).json({
      status: 'success',
      message: 'Message removed successfully'
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Error removing message',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}

export async function getAllQueues(req: Request, res: Response): Promise<any> {
  try {
    const queues = messageQueue.getAllQueues();
    res.status(200).json({
      status: 'success',
      data: queues
    });
  } catch (error) {
    res.status(500).json({
      status: 'error',
      message: 'Error getting all queues',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}
