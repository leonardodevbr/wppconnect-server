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
      const updateData = {
        sessionName,
        webhook: this.client.config?.webhook || '',
        config: JSON.stringify(this.client.config || {}),
        WABrowserId: tokenData?.WABrowserId || undefined,
        WASecretBundle: tokenData?.WASecretBundle || undefined,
        WAToken1: tokenData?.WAToken1 || undefined,
        WAToken2: tokenData?.WAToken2 || undefined,
      };

      // Remover campos undefined para não sobrescrever com null
      Object.keys(updateData).forEach((key) =>
        (updateData as any)[key] === undefined && delete (updateData as any)[key]
      );

      return (await (Token as any).findOneAndUpdate(
        { sessionName },
        { $set: updateData },
        { upsert: true, new: true }
      ))
        ? true
        : false;
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
