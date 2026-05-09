import { ServerOptions } from './types/ServerOptions';

function requireEnv(name: string): string {
  const value = process.env[name];
  if (value === undefined || String(value).trim() === '') {
    throw new Error(`[WPPConnect] ${name} não definida`);
  }
  return value;
}

const isProduction = process.env.NODE_ENV === 'production';

const secretKey = requireEnv('SECRET_KEY');
const mongoURLRemote = requireEnv('MONGODB_URI');

let redisHost = process.env.REDIS_HOST?.trim();
if (!redisHost && !isProduction) {
  redisHost = 'localhost';
}
if (isProduction && !redisHost) {
  throw new Error('[WPPConnect] REDIS_HOST não definido');
}

export default {
  secretKey,
  host: process.env.HOST || 'http://localhost',
  port: process.env.PORT || '3000',
  phoneNumber: process.env.PHONE_NUMBER,
  deviceName: 'WppConnect',
  poweredBy: 'WppConnect',
  startAllSession: true,
  tokenStoreType: 'mongodb',
  maxListeners: 10,
  customUserDataDir: './userDataDir/',
  webhook: {
    url:
      process.env.WEBHOOK_URL?.trim() ||
      process.env.CALLBACK_URL?.trim() ||
      '',
    autoDownload: false,
    uploadS3: false,
    readMessage: true,
    allUnreadOnStart: false,
    listenAcks: process.env.WEBHOOK_LISTEN_ACKS === 'true',
    onPresenceChanged: false,
    onParticipantsChanged: false,
    onReactionMessage: false,
    onPollResponse: false,
    onRevokedMessage: false,
    onLabelUpdated: false,
    onSelfMessage: true,
    ignore: [
      'status@broadcast',
      'qrcode',
      'status-find', 
      'onpresencechanged',
      'incomingcall',
    ],
  },
  websocket: {
    autoDownload: false,
    uploadS3: false,
  },
  chatwoot: {
    sendQrCode: true,
    sendStatus: true,
  },
  archive: {
    enable: false,
    waitTime: 10,
    daysToArchive: 45,
  },
  log: {
    level: process.env.LOG_LEVEL || 'info',
    logger:
      process.env.LOG_CONSOLE === 'true' && process.env.LOG_FILE === 'true'
        ? ['console', 'file']
        : process.env.LOG_CONSOLE === 'true'
          ? ['console']
          : ['file'],
  },
  logQR: false,
  createOptions: {
    browserArgs: [
      '--disable-web-security',
      '--no-sandbox',
      '--disable-web-security',
      '--aggressive-cache-discard',
      '--disable-cache',
      '--disable-application-cache',
      '--disable-offline-load-stale-cache',
      '--disk-cache-size=0',
      '--disable-background-networking',
      '--disable-default-apps',
      '--disable-extensions',
      '--disable-sync',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--disable-translate',
      '--hide-scrollbars',
      '--metrics-recording-only',
      '--mute-audio',
      '--no-first-run',
      '--safebrowsing-disable-auto-update',
      '--ignore-certificate-errors',
      '--ignore-ssl-errors',
      '--ignore-certificate-errors-spki-list',
    ],
    /**
     * Example of configuring the linkPreview generator
     * If you set this to 'null', it will use global servers; however, you have the option to define your own server
     * Clone the repository https://github.com/wppconnect-team/wa-js-api-server and host it on your server with ssl
     *
     * Configure the attribute as follows:
     * linkPreviewApiServers: [ 'https://www.yourserver.com/wa-js-api-server' ]
     */
    linkPreviewApiServers: null,
    autoClose: parseInt(process.env.AUTO_CLOSE_TIMEOUT || '300', 10) * 1000,
    waitForLogin: false,
  },
  mapper: {
    enable: false,
    prefix: 'tagone-',
  },
  db: {
    mongodbDatabase: process.env.MONGODB_DATABASE || 'wppconnect',
    mongodbCollection: process.env.MONGODB_COLLECTION || 'WppConnect',
    mongodbUser: process.env.MONGODB_USERNAME,
    mongodbPassword: process.env.MONGODB_PASSWORD,
    mongodbHost: process.env.MONGODB_HOST || 'localhost',
    mongoIsRemote: true,
    mongoURLRemote,
    mongodbPort: parseInt(process.env.MONGODB_PORT || '27017', 10),
    redisHost: redisHost as string,
    redisPort: parseInt(process.env.REDIS_PORT || '6379', 10),
    redisPassword: process.env.REDIS_PASSWORD ?? '',
    redisDb: parseInt(process.env.REDIS_DB || '0', 10),
    redisPrefix: 'wppconnect',
  },
  aws_s3: {
    region: (process.env.AWS_REGION || 'sa-east-1') as string,
    access_key_id: process.env.AWS_ACCESS_KEY_ID ?? null,
    secret_key: process.env.AWS_SECRET_ACCESS_KEY ?? null,
    defaultBucketName: process.env.AWS_BUCKET_NAME ?? null,
    endpoint: null,
    forcePathStyle: null,
  },
} as unknown as ServerOptions;
