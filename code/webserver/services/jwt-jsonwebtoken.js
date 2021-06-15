const jwt = require('jsonwebtoken')
const moment = require('moment');
const access_secret = process.env.ACCESS_SECRET;
const refresh_secret = process.env.REFRESH_SECRET;

const refreshArray = [];

module.exports.generateAccess =  (userEmail) => {
    const accessToken = jwt.sign({ iss: userEmail }, access_secret, { expiresIn: '7d'});
    return accessToken;
};

module.exports.generateRefresh =  (userEmail) => {
  for (var i = 0; i < refreshArray.length; i++) {
    if (refreshArray[i]['email'] == userEmail) {
      return refreshArray[i]['refresh'];
    }
  }

  const refreshToken = jwt.sign({ iss: userEmail }, refresh_secret);
  refreshArray.push({email : userEmail, refresh: refreshToken});
  console.log('Pushed refresh');
  return refreshToken;
};

module.exports.verifyAccess = (access_token) => {
    return new Promise((resolve, reject) => {
        if(!access_token) return reject('Access token is missing/null');
        if(jwt.verify(access_token, access_secret, (err, payload) => {
            if(err) return reject(err);
            return resolve(access_token);
        }));
    })
}

module.exports.verifyRefresh = (refresh_token, next) => {
    return new Promise((resolve, reject) => {
        if(!refresh_token) return reject('Refresh token is missing/null');

        for(i =0 ; i < refreshArray.length; i++) {
            if(refreshArray[i].refresh === refresh_token) {
                if(jwt.verify(refresh_token, refresh_secret, (err, payload) => {
                    if(err) return reject(err);
                    return resolve(refreshArray[i]);
                }));
            }
        }

        return reject('Refresh token is not valid');
    })
}

module.exports.deleteRefresh = (refresh_token, next) => {
    return new Promise((resolve, reject) => {
        if(!refresh_token) return reject('Refresh token is missing/null');

        for(i =0 ; i < refreshArray.length; i++) {
            if(refreshArray[i].refresh === refresh_token) {
                if(jwt.verify(refresh_token, refresh_secret, (err, payload) => {
                    if(err) return reject(err);
                    refreshArray.splice(i, 1);
                    return resolve();
                }));
            }
        }

        return reject('Refresh token is not valid');
    })
}
