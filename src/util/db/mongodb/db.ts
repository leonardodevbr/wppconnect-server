//import mongoose from 'mongoose';
import config from '../../../config';

const mongoose =
  config.tokenStoreType === 'mongodb' ? require('mongoose') : null;

if (config.tokenStoreType === 'mongodb') {
  mongoose.Promise = global.Promise;
  const userAndPassword =
    config.db.mongodbUser && config.db.mongodbPassword
      ? `${config.db.mongodbUser}:${config.db.mongodbPassword}@`
      : '';

  if (!config.db.mongoIsRemote) {
    mongoose.connect(
      `mongodb://${userAndPassword}${config.db.mongodbHost}:${config.db.mongodbPort}/${config.db.mongodbDatabase}`
    );
  } else {
    mongoose.connect(config.db.mongoURLRemote);
  }
}

export default mongoose;
