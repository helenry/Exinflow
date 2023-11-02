module.exports = (sequelize, DataTypes) => {
    const Categories = sequelize.define("Categories", {
        Id: {
            type: DataTypes.BIGINT,
            primaryKey: true,
            autoIncrement: true,
            allowNull: false
        },
        Name: {
            type: DataTypes.STRING,
            allowNull: false
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
    
    return Categories;
};