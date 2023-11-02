const fs = require("fs");
const path = require("path");
require("dotenv").config({path: path.join(__dirname, ".env")});
const express = require("express");
const http = require("http");
const swaggerjsdoc = require("swagger-jsdoc");
const swaggerui = require("swagger-ui-express");

const app = express();
app.use(express.json());
app.use(express.urlencoded({
    extended: true
}));

fs.readdirSync("./src/routes").forEach(file => {
    if (file.endsWith(".js")) {
        const route = require(path.join(__dirname, "src", "routes", file));
        app.use("/api/", route);
    }
});

const options = {
    definition: {
        openapi: "3.0.3",
        info: {
            title: "Exinflow API Documentation",
            version: "0.1"
        },
        servers: [
            {
                url: `http://localhost:${process.env.PORT}/`
            }
        ],
        components: {
            securitySchemes: {
                bearerAuth: {
                    type: 'http',
                    scheme: 'bearer',
                    bearerFormat: 'JWT',
                },
            },
        }
    },
    apis: ["./src/routes/*.js"]
};
const doc = swaggerjsdoc(options);
app.use(
    "/api/docs",
    swaggerui.serve,
    swaggerui.setup(doc)
);
    
const server = http.createServer(app);
server.listen(process.env.PORT, () => {
    console.log(`===== Server is Listening on Port ${process.env.PORT} =====`)
})