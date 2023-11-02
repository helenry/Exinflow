const db = require("../models");
const _ = require("lodash");
const {authorization} = require("../utils/authorization");

const wallet = {
    GetAll: async(req, res) => {
        const {user} = authorization(req.headers.authorization);

        try{
            await db.Wallets.findAll({
                attributes: {
                    exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                },
                where: {
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            .then(result => {
                return res.json({
                    success: true,
                    message: "Success to get all wallets data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get all wallets data",
                error: e.toString()
            });
        }
    },
    GetOne: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;

        try{
            await db.Wallets.findOne({
                attributes: {
                    exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                },
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            .then(result => {
                return res.json({
                    success: true,
                    message: "Success to get wallet data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get wallet data",
                error: e.toString()
            });
        }
    },
    Post: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        const {Name, InitialSaldo} = req.body;

        try{
            await db.Wallets.create({
                Name,
                InitialSaldo,
                CrtBy: user.Id
            });
            
            return res.json({
                success: true,
                message: "Success post wallet data"
            });
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed post wallet data",
                error: e.toString()
            });
        }
    },
    Patch: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;
        const {Name, InitialSaldo} = req.body;

        try{
            const wallet = await db.Wallets.findOne({
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            
            if(!_.isNull(wallet)) {
                wallet.Name = Name;
                wallet.InitialSaldo = InitialSaldo;
                wallet.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await wallet.save();
                
                return res.json({
                    success: true,
                    message: "Success patch wallet data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "Wallet data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed patch wallet data",
                error: e.toString()
            });
        }
    },
    Delete: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;

        try{
            const wallet = await db.Wallets.findOne({
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            
            if(!_.isNull(wallet)) {
                wallet.IsDelete = 1;
                wallet.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await wallet.save();
                
                return res.json({
                    success: true,
                    message: "Success delete wallet data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "Wallet data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed delete wallet data",
                error: e.toString()
            });
        }
    }
};

module.exports = wallet;