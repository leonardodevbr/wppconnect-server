# ✅ CORREÇÃO: Limpeza Automática de Lock Files

## **PROBLEMA RESOLVIDO:**

O sistema agora **automaticamente remove lock files** do Chromium antes de iniciar uma sessão, permitindo **sobrescrever** qualquer sessão travada.

## **O QUE FOI ADICIONADO:**

### **Arquivo:** `src/util/createSessionUtil.ts`

```typescript
// Limpar lock files do Chromium que podem estar travando a sessão
try {
  const lockFiles = [
    path.join(userDataDir, 'SingletonLock'),
    path.join(userDataDir, 'Default', 'SingletonLock'),
    path.join(userDataDir, 'SingletonSocket'),
    path.join(userDataDir, 'Default', 'SingletonSocket'),
    path.join(userDataDir, 'lockfile'),
    path.join(userDataDir, 'Default', 'lockfile'),
  ];
  
  for (const lockFile of lockFiles) {
    if (fs.existsSync(lockFile)) {
      req.logger.info(`[${session}] Removendo lock file: ${lockFile}`);
      fs.unlinkSync(lockFile);
    }
  }
} catch (error) {
  req.logger.warn(`[${session}] Erro ao remover lock files: ${error}`);
}
```

## **RESULTADO:**

✅ Lock files são **automaticamente removidos** antes de iniciar qualquer sessão  
✅ Permite **sobrescrever** sessões travadas  
✅ Não precisa mais fechar manualmente ou deletar arquivos  
✅ Logs mostram quando lock files são removidos  

**Agora você pode iniciar qualquer sessão sem preocupação com locks!**
