module.exports = (sequelize, DataTypes) => {
    const Users = sequelize.define("Users", {
        Id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false
        },
        Email: {
            type: DataTypes.STRING,
            allowNull: false
        },
        Phone: {
            type: DataTypes.STRING,
            allowNull: false
        },
        Password: {
            type: DataTypes.STRING,
            allowNull: false
        },
        FullName: {
            type: DataTypes.STRING,
            allowNull: false
        },
        CrtAt: {
            type: "TIMESTAMP",
            allowNull: false,
            defaultValue: sequelize.literal('CURRENT_TIMESTAMP')
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
    
    return Users;
};