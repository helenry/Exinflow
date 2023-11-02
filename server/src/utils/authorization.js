require("dotenv").config();
const jwt = require("jsonwebtoken");

module.exports = {
    authorization: (bearerToken) => {
        let token =  bearerToken.slice(7);
        const user = jwt.verify(token, process.env.JWT_KEY);
        return user;
    }
}