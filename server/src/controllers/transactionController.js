const db = require("../models");
const _ = require("lodash");
const {authorization} = require("../utils/authorization");

const transaction = {
    GetAll: async(req, res) => {
        const {user} = authorization(req.headers.authorization);

        try{
            await db.Transactions.findAll({
                attributes: {
                    exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                },
                where: {
                    IsDelete: 0,
                    CrtBy: user.Id
                },
                include: [
                    {
                        model: db.Wallets,
                        as: "walletfrom",
                        attributes: {
                            exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                        },
                        where: {
                            IsDelete: 0
                        },
                        required: false
                    },
                    {
                        model: db.Wallets,
                        as: "walletto",
                        attributes: {
                            exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                        },
                        where: {
                            IsDelete: 0
                        },
                        required: false
                    },
                    {
                        model: db.Categories,
                        as: "category",
                        attributes: {
                            exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                        },
                        where: {
                            IsDelete: 0
                        },
                        required: false
                    }
                ]
            })
            .then(result => {
                return res.json({
                    success: true,
                    message: "Success to get all transactions data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get all transactions data",
                error: e.toString()
            });
        }
    },
    GetOne: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;

        try{
            await db.Transactions.findOne({
                attributes: {
                    exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                },
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                },
                include: [
                    {
                        model: db.Wallets,
                        as: "walletfrom",
                        attributes: {
                            exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                        },
                        where: {
                            IsDelete: 0
                        },
                        required: false
                    },
                    {
                        model: db.Wallets,
                        as: "walletto",
                        attributes: {
                            exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                        },
                        where: {
                            IsDelete: 0
                        },
                        required: false
                    },
                    {
                        model: db.Categories,
                        as: "category",
                        attributes: {
                            exclude: ["CrtAt", "CrtBy", "UpdAt", "IsDelete"]
                        },
                        where: {
                            IsDelete: 0
                        },
                        required: false
                    }
                ]
            })
            .then(result => {
                return res.json({
                    success: true,
                    message: "Success to get transaction data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get transaction data",
                error: e.toString()
            });
        }
    },
    Post: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        const {TransactionType, CategoryId, WalletFromId, WalletToId, Amount, Description} = req.body;

        try{
            await db.Transactions.create({
                TransactionType,
                CategoryId,
                WalletFromId,
                WalletToId,
                Amount,
                Description,
                CrtBy: user.Id
            });
            
            return res.json({
                success: true,
                message: "Success post transaction data"
            });
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed post transaction data",
                error: e.toString()
            });
        }
    },
    Patch: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;
        const {TransactionType, CategoryId, WalletFromId, WalletToId, Amount, Description} = req.body;

        try{
            const transaction = await db.Transactions.findOne({
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            
            if(!_.isNull(transaction)) {
                transaction.TransactionType = TransactionType;
                transaction.CategoryId = CategoryId;
                transaction.WalletFromId = WalletFromId;
                transaction.WalletToId = WalletToId;
                transaction.Amount = Amount;
                transaction.Description = Description;
                transaction.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await transaction.save();
                
                return res.json({
                    success: true,
                    message: "Success patch transaction data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "Transaction data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed patch transaction data",
                error: e.toString()
            });
        }
    },
    Delete: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;

        try{
            const transaction = await db.Transactions.findOne({
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            
            if(!_.isNull(transaction)) {
                transaction.IsDelete = 1;
                transaction.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await transaction.save();
                
                return res.json({
                    success: true,
                    message: "Success delete transaction data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "Transaction data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed delete transaction data",
                error: e.toString()
            });
        }
    }
};

module.exports = transaction;