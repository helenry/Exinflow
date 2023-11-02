const db = require("../models");
const _ = require("lodash");
const {authorization} = require("../utils/authorization");

const category = {
    GetAll: async(req, res) => {
        const {user} = authorization(req.headers.authorization);

        try{
            await db.Categories.findAll({
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
                    message: "Success to get all categories data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get all categories data",
                error: e.toString()
            });
        }
    },
    GetOne: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;

        try{
            await db.Categories.findOne({
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
                    message: "Success to get category data",
                    data: result
                });
            })
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed to get category data",
                error: e.toString()
            });
        }
    },
    Post: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        const {Name} = req.body;

        try{
            await db.Categories.create({
                Name,
                CrtBy: user.Id
            });
            
            return res.json({
                success: true,
                message: "Success post category data"
            });
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed post category data",
                error: e.toString()
            });
        }
    },
    Patch: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;
        const {Name} = req.body;

        try{
            const category = await db.Categories.findOne({
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            
            if(!_.isNull(category)) {
                category.Name = Name;
                category.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await category.save();
                
                return res.json({
                    success: true,
                    message: "Success patch category data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "Category data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed patch category data",
                error: e.toString()
            });
        }
    },
    Delete: async(req, res) => {
        const {user} = authorization(req.headers.authorization);
        let {id} = req.params;

        try{
            const category = await db.Categories.findOne({
                where: {
                    Id: id,
                    IsDelete: 0,
                    CrtBy: user.Id
                }
            })
            
            if(!_.isNull(category)) {
                category.IsDelete = 1;
                category.UpdAt = db.sequelize.literal("CONVERT_TZ(NOW(), '+00:00', '+07:00')");
                await category.save();
                
                return res.json({
                    success: true,
                    message: "Success delete category data"
                });
            } else {
                return res.json({
                    success: false,
                    message: "Category data doesn't exist"
                });
            }
            
        } catch(e) {
            return res.json({
                success: false,
                message: "Failed delete category data",
                error: e.toString()
            });
        }
    }
};

module.exports = category;