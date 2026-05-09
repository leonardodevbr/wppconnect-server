# 📍 Rota: POST /api/:session/start

## **Localização:**
`src/routes/index.ts` - Linhas 148-220

## **Funcionamento:**
1. Verifica se instância já existe (linha 152)
2. Se existe, retorna QR Code REAL (linhas 155-165)
3. Se não existe, chama SessionController.startSession() (linha 175)
4. Aguarda 2 segundos para QR Code ser gerado (linha 178)
5. Retorna QR Code REAL do WPPConnect (linhas 182-192)
6. Se falhar, usa fallback com QR Code mockado (linhas 195-212)

## **Uso:**
```bash
POST http://localhost:3000/api/test-session/start
```

## **Exemplo de resposta:**
```json
{
  "status": "success",
  "message": "Instância iniciada com sucesso",
  "data": {
    "status": "QRCODE",
    "qrcode": "data:image/png;base64,...",
    "urlcode": "..."
  }
}
```
