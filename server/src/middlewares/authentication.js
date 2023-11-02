require("dotenv").config();
const jwt = require("jsonwebtoken");

module.exports = {
    authentication: (req, res, next) => {
        let token = req.headers.authorization;
        if(!token) {
            return res.status(401).json({
                success : false,
                code    : 401,
                message : "Unauthorized token"
            });
        } else {
            token = token.slice(7);
            jwt.verify(token, process.env.JWT_KEY, (error, decoded) => {
                if(error) {
                    return res.status(401).json({
                        success : false,
                        code    : 401,
                        message : "Unauthorized token"
                    });
                } else {
                    return next();
                }
            });
        }
    }
};