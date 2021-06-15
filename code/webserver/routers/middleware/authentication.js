const bcrypt = require('bcrypt');
const token = require('../../services/jwt-jsonwebtoken');

module.exports.auth_access = (req, res, next) => {
    // Use custom error
    if(!req.headers['authorization']) return res.status(403).send({message : 'Invalid access token'});
    const accessToken = (req.headers['authorization']).split(' ')[1];

    token.verifyAccess(accessToken).then((token) => {
        next();
    }).catch(err => {
        return res.status(403).send({message : err.name + ' : ' + err.message});
    })
};

module.exports.auth_refresh = (req, res, next) => {
    if(!req.headers['authorization']) return res.status(403).send({message : 'Invalid refresh token'});
    const refreshToken = (req.headers['authorization']).split(' ')[1];

    token.verifyRefresh(refreshToken).then((token) => {
        req.data = token;
        next();
    }).catch(err => {
        return res.status(403).send({message : err.name + ' : ' + err.message});
    })
}

module.exports.delete_refresh = (req, res, next) => {
    if(!req.headers['authorization']) return res.status(403).send({message : 'Invalid refresh token'});
    const refreshToken = (req.headers['authorization']).split(' ')[1];

    token.deleteRefresh(refreshToken).then((token) => {
        next();
    }).catch(err => {
        return res.status(403).send({message : err.name + ' : ' + err.message});
    })
}

module.exports.hash_password = function (password) {
    return new Promise( (resolve, reject) => {
        bcrypt.genSalt(10, (err, salt) => {
            if(err) return reject(err);

            bcrypt.hash(password, salt, (error, hash) => {
                if(err) return reject(err);
                return resolve(hash);
            });
        });
    });
};

module.exports.auth_password = (password, hash) => {
    return new Promise((resolve, reject) => {
        bcrypt.compare(password, hash, (err, response) => {
            if(err) return reject(err);
            return resolve(response);
        });
    });
};
