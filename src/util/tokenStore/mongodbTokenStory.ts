import Token from './model/token';

class MongodbTokenStore {
  declare client: any;
  constructor(client: any) {
    this.client = client;
  }
  tokenStore = {
    getToken: async (sessionName: string) => {
      let result = await (Token as any).findOne({ sessionName });
      if (result === null) return result;
      result = JSON.parse(JSON.stringify(result));
      result.config = result.config ? JSON.parse(result.config) : {};
      result.config.webhook = result.webhook;
      this.client.config = result.config;
      return result;
    },
    setToken: async (sessionName: any, tokenData: any) => {
      console.log('[setToken] salvando sessão:', sessionName, 'tokenData keys:', Object.keys(tokenData || {}));

      const updateData: any = {
        sessionName,
        webhook: this.client.config?.webhook || '',
        config: JSON.stringify(this.client.config || {}),
      };

      // Salvar todos os campos WAToken que o WPPConnect passar
      if (tokenData?.WABrowserId) updateData.WABrowserId = tokenData.WABrowserId;
      if (tokenData?.WASecretBundle) updateData.WASecretBundle = tokenData.WASecretBundle;
      if (tokenData?.WAToken1) updateData.WAToken1 = tokenData.WAToken1;
      if (tokenData?.WAToken2) updateData.WAToken2 = tokenData.WAToken2;

      return (await (Token as any).findOneAndUpdate(
        { sessionName },
        { $set: updateData },
        { upsert: true, new: true }
      )) ? true : false;
    },
    removeToken: async (sessionName: string) => {
      return (await (Token as any).deleteOne({ sessionName })) ? true : false;
    },
    listTokens: async () => {
      const result = await (Token as any).find();
      return result.map((m: any) => m.sessionName);
    },
  };
}

export default MongodbTokenStore;
