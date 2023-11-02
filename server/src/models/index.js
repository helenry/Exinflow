require("dotenv").config();
const {Sequelize, DataTypes} = require("sequelize");

const sequelize = new Sequelize({
    dialect: "mysql",
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    username: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    define: {
        timestamps: false,
        underscored: false
    },
    dialectOptions: {
        requestTimeout: 600000,
        encrypt: false
    }
});

sequelize.authenticate()
.then(() => {
    console.log(`===== Database Connection: ${process.env.DB_HOST}:${process.env.DB_PORT} =====`);
});

const db = {};
db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.Users = require("./Users.js")(sequelize, DataTypes);
db.Categories = require("./Categories.js")(sequelize, DataTypes);
db.Wallets = require("./Wallets.js")(sequelize, DataTypes);
db.Transactions = require("./Transactions.js")(sequelize, DataTypes);

db.sequelize.sync({force: false})
.then(() => {
    console.log("===== Database Synced Successfully =====");
});

db.Wallets.hasMany(db.Transactions, {
    foreignKey: "WalletFromId",
    as: "walletfrom"
})

db.Wallets.hasMany(db.Transactions, {
    foreignKey: "WalletToId",
    as: "walletto"
})

db.Categories.hasMany(db.Transactions, {
    foreignKey: "CategoryId",
    as: "category"
})

db.Transactions.belongsTo(db.Wallets, {
    foreignKey: "WalletFromId",
    as: "walletfrom"
})

db.Transactions.belongsTo(db.Wallets, {
    foreignKey: "WalletToId",
    as: "walletto"
})

db.Transactions.belongsTo(db.Categories, {
    foreignKey: "CategoryId",
    as: "category"
})

module.exports = db;