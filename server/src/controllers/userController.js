const db = require("../models");
const _ = require("lodash");
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const {authorization} = require("../utils/authorization");

const User = {
    GetOne: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        
        try{
            await db.Users.findOne({
                attributes: {
                    exclude: ["Password", "CrtAt", "UpdAt", "IsDelete"]
                },
                where: {
                    Id: user.Id,
                    IsDelete: 0
                }
            })
            .then(result => {
                return res.json({
                    success: true,
                    message: "Success to get user data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get user data",
                error: e.toString()
            });
        }
    },
    LogIn: async(req, res) => {
        const {Email, Password} = req.body;

        try {
            await db.Users.findOne({
                where: {
                    Email: Email,
                    IsDelete: 0
                }
            })
            .then(user => {
                if(!_.isNull(user)){
                    bcrypt.compare(Password, user.Password, (e, result) => {
                        if(result === true) {
                            let userData = {
                                Id: user.Id,
                                Email: user.Email,
                                Phone: user.Phone,
                                FullName: user.FullName
                            }

                            const token = jwt.sign(
                                {user: userData},
                                process.env.JWT_KEY
                            )

                            return res.json({
                                success: true,
                                message: "Log in success",
                                payload: {
                                    user: userData,
                                    token: token
                                }
                            });
                        }
                    })
                } else {
                    return res.json({
                        success: false,
                        message: "Email doesn't exist"
                    });
                }
            });
        } catch(e) {
            return res.json({
                success : false,
                message : "Log in failed",
                error: e.toString()
            });
        }
    },
    SignUp: async(req, res) => {
        const {Email, Phone, Password, FullName} = req.body;

        try{
            bcrypt.hash(Password, 10, async(e, hash) => {
                await db.Users.create({
                    Email,
                    Phone,
                    Password: hash,
                    FullName
                });
                
                return res.json({
                    success: true,
                    message: "Sign up success"
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Sign up failed",
                error: e.toString()
            });
        }
    },
    Patch: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        const {Email, Phone, FullName} = req.body;

        try{
            const user = await db.Users.findOne({
                where: {
                    Id: user.Id,
                    IsDelete: 0,
                }
            })
            
            if(!_.isNull(user)) {
                user.Email = Email;
                user.Phone = Phone;
                user.FullName = FullName;
                user.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await user.save();
                
                return res.json({
                    success: true,
                    message: "Success patch user data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "User data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed patch user data",
                error: e.toString()
            });
        }
    },
    Delete: async(req, res) => {
        const {user} = authorization(req.headers.authorization);

        try{
            const user = await db.Users.findOne({
                where: {
                    Id: user.Id,
                    IsDelete: 0
                }
            })
            
            if(!_.isNull(user)) {
                user.IsDelete = 1;
                user.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await user.save();
                
                return res.json({
                    success: true,
                    message: "Success delete user data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "User data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed delete user data",
                error: e.toString()
            });
        }
    }
};

module.exports = User;