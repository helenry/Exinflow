/**
 * @swagger
 * components:
 *   schemas:
 *     Users:
 *       type: object
 *       required:
 *         - Email
 *         - Phone
 *         - Password
 *         - FullName
 *       properties:
 *         Id:
 *           type: string
 *           description: The unique identifier of the user
 *         Email:
 *           type: string
 *           description: The email of the user
 *         Phone:
 *           type: string
 *           description: The phone of the user
 *         Password:
 *           type: string
 *           description: The password of the user
 *         FullName:
 *           type: string
 *           description: The name of the user
 *         CrtAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the user was created
 *         UpdAt:
 *           type: string
 *           format: date-time
 *           description: The date and time when the user was last updated
 *         IsDelete:
 *           type: boolean
 *           description: Indicates whether the user is marked as deleted (true) or active (false)
 * 
 * tags:
 *   name: User
 *   description: API to sign up, log in, and manipulate user data
 * securityDefinitions:
 *   bearerAuth:
 *     type: apiKey
 *     name: Authorization
 *     in: header
 * 
 * /api/signup:
 *   post:
 *     summary: Sign up
 *     tags: [User]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Users'
 *     responses:
 *       200:
 *         description: The created user.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Users'
 *       500:
 *         description: Some server error
 * 
 * /api/login:
 *   post:
 *     summary: Log in
 *     tags: [User]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/Users'
 *     responses:
 *       200:
 *         description: The created user.
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Users'
 *       500:
 *         description: Some server error
 * 
 * /api/user:
 *   get:
 *     summary: Get logged in user data
 *     security:
 *       - bearerAuth: []
 *     tags: [User]
 *     responses:
 *       200:
 *         description: The list of the users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 $ref: '#/components/schemas/Users'
 * 
 *   patch:
 *    summary: Update logged in user data
 *    security:
 *      - bearerAuth: []
 *    tags: [User]
 *    parameters:
 *      - in: path
 *        name: id
 *        schema:
 *          type: string
 *        required: true
 *        description: The user id
 *    requestBody:
 *      required: true
 *      content:
 *        application/json:
 *          schema:
 *            $ref: '#/components/schemas/Users'
 *    responses:
 *      200:
 *        description: The user was updated
 *        content:
 *          application/json:
 *            schema:
 *              $ref: '#/components/schemas/Users'
 *      404:
 *        description: The user was not found
 *      500:
 *        description: Some error happened
 * 
 *   delete:
 *     summary: Remove logged in user data
 *     security:
 *       - bearerAuth: []
 *     tags: [User]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: string
 *         required: true
 *         description: The user id
 *
 *     responses:
 *       200:
 *         description: The user was deleted
 *       404:
 *         description: The user was not found
 * 
 */

const express = require("express");
const router = express.Router();
const {authentication} = require("../middlewares/authentication")
const User = require("../controllers/userController")

router.get("/user", authentication, User.GetOne);
router.post("/login", User.LogIn);
router.post("/signup", User.SignUp);
router.patch("/user", authentication, User.Patch);
router.delete("/user", authentication, User.Delete);

module.exports = router;