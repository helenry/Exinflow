module.exports = (sequelize, DataTypes) => {
    const Transactions = sequelize.define("Transactions", {
        Id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false
        },
        TransactionType: {
            type: DataTypes.BIGINT,
            allowNull: false
        },
        CategoryId: {
            type: DataTypes.BIGINT,
            allowNull: false
        },
        WalletFromId: {
            type: DataTypes.BIGINT,
            allowNull: true
        },
        WalletToId: {
            type: DataTypes.BIGINT,
            allowNull: true
        },
        Amount: {
            type: DataTypes.BIGINT,
            allowNull: false
        },
        Description: {
            type: DataTypes.STRING,
            allowNull: true
        },
        CrtAt: {
            type: "TIMESTAMP",
            allowNull: false,
            defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
        },
        CrtBy: {
            type: DataTypes.BIGINT,
            allowNull: false
        },
        UpdAt: {
            type: DataTypes.DATE,
            allowNull: true
        },
        IsDelete: {
            type: DataTypes.INTEGER,
            defaultValue: 0
        }
    });
    
    return Transactions;
};